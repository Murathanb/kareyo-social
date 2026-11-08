#!/bin/zsh
# Tüm içeriği yeniden üretir: plan → müzik → reels (müzikli) + kapaklar → görseller.
# Kullanım: tools/build.sh   (marketing/social içinden)
# Not: "reel-sequence" reels'leri uygulamanın kendi Reels motoruyla simülatörde üretilip
# content/build/raw-reels/<id>.mp4 olarak buraya konuyor (bkz. README → İçerik üretimi).
set -e
cd "${0:A:h}/.."
ROOT=$PWD
APP=$ROOT/../../ios/App/Resources
FONTS=$APP/Fonts
ICON=$APP/Assets.xcassets/IconPreview-default.imageset/IconPreview-default@3x.png
BIN=$ROOT/content/build/bin
mkdir -p $BIN $ROOT/content/build/raw-reels $ROOT/content/media $ROOT/content/audio

/usr/bin/python3 -I tools/plan.py

echo "› araçlar derleniyor"
mkdir -p $BIN/src-images $BIN/src-video
cp tools/images.swift $BIN/src-images/main.swift
cp tools/video.swift $BIN/src-video/main.swift
swiftc -O -o $BIN/images tools/kit.swift $BIN/src-images/main.swift
swiftc -O -o $BIN/video tools/kit.swift $BIN/src-video/main.swift
swiftc -O -o $BIN/music tools/music.swift

echo "› müzik"
for s in sakin parlak hareketli; do
  [ -f content/audio/$s.m4a ] || $BIN/music $s 20 content/audio/$s.m4a
done

echo "› reels"
/usr/bin/python3 -I -c "
import json
for i in json.load(open('content/plan.json'))['items']:
    if i['kind'] == 'reel':
        r = i['render']; print(i['id'], r['template'], r.get('music', 'parlak'), r.get('path', ''))
" | while read id template music src; do
  raw=content/build/raw-reels/$id.mp4
  case $template in
    reel-sequence) [ -f $raw ] || { echo "EKSİK: $raw (simülatörde üret)"; continue } ;;
    reel-file) raw=content/sources/$src.mp4 ;;
    *) $BIN/video render $ROOT $FONTS $ICON $id $raw ;;
  esac
  mkdir -p content/media/$id
  $BIN/video mux $raw content/audio/$music.m4a content/media/$id/reel.mp4
  $BIN/video cover content/media/$id/reel.mp4 2.2 content/media/$id/cover.jpg
done

echo "› görseller"
$BIN/images $ROOT $FONTS $ICON

/usr/bin/python3 -I tools/check.py
