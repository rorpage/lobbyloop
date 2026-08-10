#!/bin/bash
# Launches Chromium in kiosk mode pointed at the local LobbyLoop server.
# Assumes server.py is already running on port 8080.

export DISPLAY=:0

# Hide the mouse cursor after it is idle. Requires unclutter.
# Install with: sudo apt install unclutter
unclutter -idle 0.5 -root &

# The Chromium binary is named differently depending on the Raspberry Pi OS
# version. Bookworm uses "chromium", older Bullseye uses "chromium-browser".
if command -v chromium >/dev/null 2>&1; then
  BROWSER_BIN="chromium"
elif command -v chromium-browser >/dev/null 2>&1; then
  BROWSER_BIN="chromium-browser"
else
  echo "Could not find chromium or chromium-browser installed. Run install.sh again, or install one manually."
  exit 1
fi

"$BROWSER_BIN" \
  --noerrdialogs \
  --disable-infobars \
  --kiosk \
  --incognito \
  --check-for-update-interval=31536000 \
  --enable-accelerated-video-decode \
  --ignore-gpu-blocklist \
  http://localhost:8080
