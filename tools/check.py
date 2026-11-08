"""Her plan öğesinin medyası var mı, Instagram sınırlarına uyuyor mu — paylaşımdan önce denetim."""
import json
import os
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MEDIA = os.path.join(ROOT, "content", "media")


def jpeg_size(path):
    with open(path, "rb") as f:
        data = f.read()
    i = 2
    while i < len(data):
        if data[i] != 0xFF:
            i += 1
            continue
        marker = data[i + 1]
        if marker in (0xC0, 0xC1, 0xC2):
            h, w = struct.unpack(">HH", data[i + 5:i + 9])
            return w, h
        length = struct.unpack(">H", data[i + 2:i + 4])[0]
        i += 2 + length
    return None


def mp4_duration(path):
    with open(path, "rb") as f:
        data = f.read()
    k = data.find(b"mvhd")
    if k < 0:
        return None
    version = data[k + 4]
    if version == 1:
        scale, dur = struct.unpack(">IQ", data[k + 24:k + 36])
    else:
        scale, dur = struct.unpack(">II", data[k + 16:k + 24])
    return dur / scale


def media_files(item_id):
    d = os.path.join(MEDIA, item_id)
    if not os.path.isdir(d):
        return []
    return sorted(f for f in os.listdir(d) if not f.startswith("."))


def check(plan):
    problems = []
    for it in plan["items"]:
        files = media_files(it["id"])
        kind = it["kind"]
        if kind == "reel":
            if "reel.mp4" not in files or "cover.jpg" not in files:
                problems.append(f"{it['id']}: reel.mp4/cover.jpg eksik")
                continue
            path = os.path.join(MEDIA, it["id"], "reel.mp4")
            dur = mp4_duration(path)
            size = os.path.getsize(path) / 1e6
            if dur is None or not (3 <= dur <= 90):
                problems.append(f"{it['id']}: süre {dur}")
            if size > 300:
                problems.append(f"{it['id']}: {size:.0f} MB")
        else:
            jpgs = [f for f in files if f.endswith(".jpg") and f != "cover.jpg"]
            want = (1080, 1920) if kind == "story" else (1080, 1350)
            if not jpgs:
                problems.append(f"{it['id']}: görsel yok")
            if kind == "carousel" and not (2 <= len(jpgs) <= 10):
                problems.append(f"{it['id']}: kaydırmalıda {len(jpgs)} kare")
            for f in jpgs:
                p = os.path.join(MEDIA, it["id"], f)
                if jpeg_size(p) != want:
                    problems.append(f"{it['id']}/{f}: boyut {jpeg_size(p)}")
                if os.path.getsize(p) > 8e6:
                    problems.append(f"{it['id']}/{f}: 8 MB'tan büyük")
        if len(it["caption"]) > 2200:
            problems.append(f"{it['id']}: açıklama çok uzun")
    return problems


if __name__ == "__main__":
    plan = json.load(open(os.path.join(ROOT, "content", "plan.json")))
    problems = check(plan)
    for p in problems:
        print("✗", p)
    print(f"{len(plan['items'])} öğe denetlendi, {len(problems)} sorun")
    sys.exit(1 if problems else 0)
