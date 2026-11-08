"""Kareyo Instagram otomatik paylaşım.

Zamanı gelen plan öğelerini Instagram Graph API (Instagram ile Giriş) üzerinden paylaşır ve
state/posted.json'a yazar. GitHub Actions her 30 dakikada bir çalıştırır; elle de denenebilir:

  python3 tools/post.py --list                 # takvimi göster (tarihleriyle)
  python3 tools/post.py --dry-run              # şu an paylaşılacakları göster, paylaşma
  python3 tools/post.py --dry-run --now 2026-12-01T19:05
  python3 tools/post.py --run                  # gerçekten paylaş (IG_USER_ID, IG_ACCESS_TOKEN gerekir)
  python3 tools/post.py --run --only g03       # tek öğeyi hemen paylaş

Kurallar:
- config.json → start_date boşsa ya da paused=true ise hiçbir şey paylaşılmaz.
- Gecikmiş hikâyeler (24 saatten eski) atlanır; gecikmiş akış gönderileri her çalıştırmada en
  fazla 1 tane paylaşılır ki birikmiş gönderiler aynı anda yığılmasın. Gün 0 ızgarası istisna.
- Her başarılı paylaşım hemen kaydedilir; yarıda kesilse bile aynı gönderi iki kez paylaşılmaz.
"""
import argparse
import datetime as dt
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from zoneinfo import ZoneInfo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(ROOT, "config.json")
STATE = os.path.join(ROOT, "state", "posted.json")
PLAN = os.path.join(ROOT, "content", "plan.json")
MEDIA = os.path.join(ROOT, "content", "media")


def load(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return default


def save_state(state):
    os.makedirs(os.path.dirname(STATE), exist_ok=True)
    tmp = STATE + ".tmp"
    with open(tmp, "w") as f:
        json.dump(state, f, ensure_ascii=False, indent=2, sort_keys=True)
    os.replace(tmp, STATE)


def schedule(item, cfg):
    tz = ZoneInfo(cfg.get("timezone", "Europe/Istanbul"))
    start = dt.date.fromisoformat(cfg["start_date"])
    h, m = map(int, item["time"].split(":"))
    d = start + dt.timedelta(days=item["day"])
    return dt.datetime(d.year, d.month, d.day, h, m, tzinfo=tz)


def media_urls(item, cfg):
    base = cfg["media_base_url"].rstrip("/") + "/content/media/" + item["id"] + "/"
    files = sorted(f for f in os.listdir(os.path.join(MEDIA, item["id"])) if not f.startswith("."))
    if item["kind"] == "reel":
        return {"video": base + "reel.mp4", "cover": base + "cover.jpg"}
    return {"images": [base + f for f in files if f.endswith(".jpg") and f != "cover.jpg"]}


# ---------------------------------------------------------------- Instagram API

class Api:
    def __init__(self, cfg):
        self.base = cfg.get("graph_api", "https://graph.instagram.com/v22.0").rstrip("/")
        self.user = os.environ["IG_USER_ID"]
        self.token = os.environ["IG_ACCESS_TOKEN"]

    def call(self, method, path, **params):
        params["access_token"] = self.token
        data = urllib.parse.urlencode(params).encode()
        url = f"{self.base}/{path}"
        if method == "GET":
            req = urllib.request.Request(url + "?" + data.decode())
        else:
            req = urllib.request.Request(url, data=data, method="POST")
        for attempt in range(3):
            try:
                with urllib.request.urlopen(req, timeout=60) as r:
                    return json.loads(r.read())
            except urllib.error.HTTPError as e:
                body = e.read().decode(errors="replace")
                if e.code >= 500 and attempt < 2:
                    time.sleep(5 * (attempt + 1))
                    continue
                raise RuntimeError(f"{method} {path} → {e.code}: {body}") from None

    def container(self, **params):
        return self.call("POST", f"{self.user}/media", **params)["id"]

    def wait(self, cid, timeout=600):
        start = time.time()
        while time.time() - start < timeout:
            status = self.call("GET", cid, fields="status_code,status").get("status_code")
            if status == "FINISHED":
                return
            if status in ("ERROR", "EXPIRED"):
                raise RuntimeError(f"konteyner {cid}: {status}")
            time.sleep(6)
        raise RuntimeError(f"konteyner {cid} zaman aşımı")

    def publish(self, cid):
        mid = self.call("POST", f"{self.user}/media_publish", creation_id=cid)["id"]
        try:
            link = self.call("GET", mid, fields="permalink").get("permalink")
        except RuntimeError:
            link = None
        return mid, link


def post(api, item, cfg):
    urls = media_urls(item, cfg)
    caption = item["caption"]
    kind = item["kind"]
    if kind == "reel":
        cid = api.container(media_type="REELS", video_url=urls["video"], cover_url=urls["cover"],
                            caption=caption, share_to_feed="true")
    elif kind == "story":
        cid = api.container(media_type="STORIES", image_url=urls["images"][0])
    elif kind == "carousel":
        children = []
        for u in urls["images"]:
            child = api.container(image_url=u, is_carousel_item="true")
            api.wait(child)
            children.append(child)
        cid = api.container(media_type="CAROUSEL", children=",".join(children), caption=caption)
    else:
        cid = api.container(image_url=urls["images"][0], caption=caption)
    api.wait(cid)
    return api.publish(cid)


# ---------------------------------------------------------------- Seçim

def due_items(plan, cfg, state, now):
    pending = [i for i in plan["items"] if i["id"] not in state]
    due, skip = [], []
    for it in sorted(pending, key=lambda i: (i["day"], i["time"])):
        when = schedule(it, cfg)
        if when > now:
            continue
        late = now - when
        if it["kind"] == "story" and late > dt.timedelta(hours=24):
            skip.append(it)
            continue
        due.append((it, late))
    # Birikmiş gecikmeleri yığmamak için: Gün 0 dışında, 2 saatten fazla gecikmiş akış
    # gönderilerinden bu çalıştırmada yalnızca en eskisi.
    selected, late_feed = [], 0
    for it, late in due:
        if it["day"] != 0 and it["kind"] != "story" and late > dt.timedelta(hours=2):
            if late_feed >= 1:
                continue
            late_feed += 1
        selected.append(it)
    return selected[: cfg.get("max_per_run", 10)], skip


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--now")
    ap.add_argument("--only")
    a = ap.parse_args()

    cfg, plan, state = load(CONFIG, {}), load(PLAN, {"items": []}), load(STATE, {})

    if a.list:
        if not cfg.get("start_date"):
            print("start_date ayarlı değil — gün farklarıyla:")
        for it in plan["items"]:
            when = schedule(it, cfg).strftime("%a %d.%m %H:%M") if cfg.get("start_date") else f"gün {it['day']:>2} {it['time']}"
            mark = "✓" if it["id"] in state else " "
            print(f"{mark} {when}  {it['kind']:<8} {it['pillar']:<10} {it['id']:<8} {it['caption'][:50].splitlines()[0] if it['caption'] else it['render']['template']}")
        return

    if not cfg.get("start_date") or cfg.get("paused"):
        print("Paylaşım kapalı (start_date boş ya da paused=true).")
        return
    tz = ZoneInfo(cfg.get("timezone", "Europe/Istanbul"))
    now = dt.datetime.fromisoformat(a.now).replace(tzinfo=tz) if a.now else dt.datetime.now(tz)

    if a.only:
        items, skipped = [i for i in plan["items"] if i["id"] == a.only and i["id"] not in state], []
    else:
        items, skipped = due_items(plan, cfg, state, now)

    for it in skipped:
        print(f"↷ atlandı (geç kalmış hikâye): {it['id']}")
        if a.run:
            state[it["id"]] = {"skipped": True, "at": now.isoformat()}
    if a.run and skipped:
        save_state(state)

    if not items:
        print("Paylaşılacak bir şey yok.", now.isoformat())
        return
    if not a.run:
        for it in items:
            print(f"→ paylaşılacak: {it['id']} ({it['kind']}) {media_urls(it, cfg)}")
        return

    api = Api(cfg)
    failures = 0
    for it in items:
        try:
            mid, link = post(api, it, cfg)
            state[it["id"]] = {"media_id": mid, "permalink": link, "at": dt.datetime.now(tz).isoformat()}
            save_state(state)
            print(f"✓ {it['id']} → {link or mid}")
            time.sleep(20)
        except Exception as e:  # bir hata diğerlerini durdurmasın; iş akışı sonunda başarısız sayılır
            failures += 1
            print(f"✗ {it['id']}: {e}", file=sys.stderr)
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
