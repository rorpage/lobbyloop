#!/bin/bash
# Launches Chromium in kiosk mode pointed at the local LobbyLoop server.
# Assumes server.py is already running on port 8080.

export DISPLAY=:0

# Hide the mouse cursor after it is idle. Requires unclutter.
# Install with: sudo apt install unclutter
unclutter -idle 0.5 -root &

chromium-browser \
  --noerrdialogs \
  --disable-infobars \
  --kiosk \
  --incognito \
  --check-for-update-interval=31536000 \
  http://localhost:8080
