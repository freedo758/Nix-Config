#!/usr/bin/env bash
# generate_thumbs.sh
#
# Syncs $THUMB_DIR to match $WALLPAPER_DIR:
#   - images  -> resized copy, same filename, in $THUMB_DIR
#   - videos  -> a poster-frame JPEG saved under "000_<original filename>"
#                (the "000_" prefix + exact original name is how
#                WallpaperPicker.qml tells thumbnails apart and maps
#                a thumb back to its real video file)
#   - any thumbnail whose source no longer exists in $WALLPAPER_DIR
#                gets deleted, so removed wallpapers actually disappear.
#
# Usage: generate_thumbs.sh <wallpaperDir> <thumbDir> [thumbSizePx]

set -euo pipefail

WALLPAPER_DIR="${1:?wallpaperDir required}"
THUMB_DIR="${2:?thumbDir required}"
THUMB_SIZE="${3:-640}"

mkdir -p "$THUMB_DIR"

if command -v magick &>/dev/null; then CONVERT="magick"; else CONVERT="convert"; fi

# Track every thumbnail filename that *should* exist this run, so we can
# prune anything left over from a deleted/renamed wallpaper afterwards.
declare -A valid_thumbs=()

shopt -s nullglob nocaseglob

for f in "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg "$WALLPAPER_DIR"/*.png \
         "$WALLPAPER_DIR"/*.webp "$WALLPAPER_DIR"/*.gif; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    thumb="$THUMB_DIR/$name"
    valid_thumbs["$name"]=1

    # (Re)generate only if missing or the source is newer than the thumb.
    if [ ! -e "$thumb" ] || [ "$f" -nt "$thumb" ]; then
        "$CONVERT" "$f" -auto-orient -resize "${THUMB_SIZE}x${THUMB_SIZE}>" "$thumb" \
            2>/dev/null || cp -f "$f" "$thumb"
    fi
done

for f in "$WALLPAPER_DIR"/*.mp4 "$WALLPAPER_DIR"/*.mkv "$WALLPAPER_DIR"/*.mov \
         "$WALLPAPER_DIR"/*.webm; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    thumbname="000_$name"
    thumb="$THUMB_DIR/$thumbname"
    valid_thumbs["$thumbname"]=1

    if [ ! -e "$thumb" ] || [ "$f" -nt "$thumb" ]; then
        if command -v ffmpeg &>/dev/null; then
            ffmpeg -y -loglevel error -ss 00:00:01 -i "$f" -frames:v 1 \
                -vf "scale=${THUMB_SIZE}:-1" "$thumb.tmp.jpg" \
                && mv -f "$thumb.tmp.jpg" "$thumb"
        fi
    fi
done

shopt -u nullglob nocaseglob

# Prune orphaned thumbnails (source wallpaper was deleted/renamed).
for t in "$THUMB_DIR"/*; do
    [ -f "$t" ] || continue
    tname=$(basename "$t")
    if [ -z "${valid_thumbs[$tname]:-}" ]; then
        rm -f "$t"
    fi
done
