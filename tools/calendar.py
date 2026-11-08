"""plan.json'dan haftalık takvimi TAKVIM.md olarak yazar (start_date ayarlıysa gerçek tarihlerle)."""
import datetime as dt
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
plan = json.load(open(os.path.join(ROOT, "content", "plan.json")))
cfg = json.load(open(os.path.join(ROOT, "config.json")))
start = dt.date.fromisoformat(cfg["start_date"]) if cfg.get("start_date") else None
DAYS = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
PHASES = {0: "Hafta 0 · Vitrin (başlangıç ızgarası)", 1: "Hafta 1-2 · Lansman (1.2)", 3: "Hafta 3-6 · #kareyo30",
          7: "Hafta 7-9 · Büyü", 10: "Hafta 10-12 · Hızlan"}
KIND = {"reel": "Reel", "carousel": "Kaydırmalı", "image": "Görsel", "story": "Hikâye"}


def week_of(day):
    return 0 if day == 0 else (day - 1) // 7 + 1


lines = ["# Kareyo Instagram · 12 haftalık takvim", ""]
lines.append(f"Başlangıç: **{start.isoformat()}** (Gün 0)" if start else "Başlangıç tarihi henüz ayarlı değil — config.json → start_date (bir Pazar).")
counts = {}
for it in plan["items"]:
    counts[it["kind"]] = counts.get(it["kind"], 0) + 1
lines += ["", "Toplam: " + " · ".join(f"{v} {KIND[k]}" for k, v in counts.items()), ""]
current = None
for it in plan["items"]:
    w = week_of(it["day"])
    if w in PHASES and w != current:
        lines += ["", f"## {PHASES[w]}", "", "| Hafta | Gün | Saat | Tür | Sütun | Konu |", "|---|---|---|---|---|---|"]
    current = w if w in PHASES else current
    if start:
        d = start + dt.timedelta(days=it["day"])
        when = f"{DAYS[d.weekday()]} {d.strftime('%d.%m')}"
    else:
        when = "Gün 0" if it["day"] == 0 else DAYS[(it["day"] - 1) % 7]
    topic = it["caption"].splitlines()[0] if it["caption"] else {
        "story-newpost": "Yeni gönderi duyurusu", "story-question": "Bugün çektin mi?",
        "story-streak": "#kareyo30 seri kontrolü", "story-tip": "Haftanın ipucu"}.get(it["render"]["template"], "")
    lines.append(f"| {w} | {when} | {it['time']} | {KIND[it['kind']]} | {it['pillar']} | {topic} |")
open(os.path.join(ROOT, "TAKVIM.md"), "w").write("\n".join(lines) + "\n")
print("TAKVIM.md yazıldı")
