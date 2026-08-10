#!/bin/bash
# Converts every GIF in the posters folder to an mp4 video of the same name.
#
# Video decoding is much lighter on a Raspberry Pi's CPU than GIF decoding,
# so converting your posters this way should fix slow or choppy playback.
#
# Requires ffmpeg. Install with:
#   sudo apt install ffmpeg
#
# Usage:
#   bash convert-posters.sh
#
# This does not delete the original GIF files. Once you confirm the mp4
# versions look right, delete the GIFs from the posters folder yourself so
# LobbyLoop only cycles through the faster video versions.

set -e

POSTER_DIR="$(dirname "$0")/posters"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is not installed. Install it with: sudo apt install ffmpeg"
  exit 1
fi

shopt -s nullglob
gif_files=("$POSTER_DIR"/*.gif "$POSTER_DIR"/*.GIF)

if [ ${#gif_files[@]} -eq 0 ]; then
  echo "No GIF files found in $POSTER_DIR."
  exit 0
fi

for gif in "${gif_files[@]}"; do
  base=$(basename "$gif")
  name="${base%.*}"
  output="$POSTER_DIR/$name.mp4"

  if [ -f "$output" ]; then
    echo "Skipping $base, $name.mp4 already exists."
    continue
  fi

  echo "Converting $base to $name.mp4..."
  ffmpeg -y -i "$gif" \
    -movflags faststart \
    -pix_fmt yuv420p \
    -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
    -c:v libx264 \
    -profile:v baseline \
    -level 3.0 \
    -crf 23 \
    "$output"
done

echo ""
echo "Done. Check the mp4 files in $POSTER_DIR."
echo "Once you're happy with them, delete the original .gif files so"
echo "LobbyLoop only cycles through the faster video versions."
