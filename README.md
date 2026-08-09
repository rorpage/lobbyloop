# LobbyLoop

Loops animated GIF movie posters fullscreen on a Raspberry Pi. Built so it can
later be extended to show whatever is currently playing on Jellyfin instead
of just looping.

## Files

- `index.html`: the page that displays and cycles the GIFs.
- `server.py`: a small Python web server that serves the page and the poster
  list. No extra Python packages needed, it only uses the standard library.
- `posters/`: put your GIF files in this folder.
- `kiosk.sh`: launches Chromium fullscreen with no window chrome and no
  visible cursor.
- `lobbyloop-server.service`: systemd unit to start `server.py` on boot.
- `lobbyloop-kiosk.service`: systemd unit to start Chromium kiosk mode on boot.
- `install.sh`: automates the setup steps below.

## Quick install

Use Raspberry Pi OS with a desktop, not the Lite version, since you need a
display session for Chromium to run in. Raspberry Pi OS with Wayland or X11
both work.

On the Pi, run:

```
curl -fsSL https://raw.githubusercontent.com/rorpage/lobbyloop/main/install.sh | sudo bash
```

This clones the repo to `/home/pi/lobbyloop`, installs Chromium and
unclutter, sets permissions, and installs and starts the two systemd
services. Running it again later pulls the latest version and restarts the
services.

After it finishes, add your GIF files to `/home/pi/lobbyloop/posters`, then
reboot:

```
sudo reboot
```

The Pi should come up straight into the poster loop with no desktop
visible.

## Manual setup

If you would rather set it up by hand, or want to understand what
`install.sh` is doing:

1. Copy this whole folder to the Pi, for example to `/home/pi/lobbyloop`.

2. Put your GIF files in `/home/pi/lobbyloop/posters`.

3. Install Chromium and unclutter if they are not already installed:
   ```
   sudo apt update
   sudo apt install chromium-browser unclutter
   ```

4. Make the kiosk script executable:
   ```
   chmod +x /home/pi/lobbyloop/kiosk.sh
   ```

5. Test it manually first, before setting up autostart:
   ```
   python3 /home/pi/lobbyloop/server.py
   ```
   Then in a separate terminal, or from another device on the same network,
   open `http://<pi-ip-address>:8080` in a browser and confirm the GIFs
   cycle correctly.

6. If that works, set up the two services so everything starts on boot:
   ```
   sudo cp lobbyloop-server.service /etc/systemd/system/
   sudo cp lobbyloop-kiosk.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable lobbyloop-server.service
   sudo systemctl enable lobbyloop-kiosk.service
   sudo systemctl start lobbyloop-server.service
   sudo systemctl start lobbyloop-kiosk.service
   ```

7. Reboot the Pi and confirm it comes up straight into the poster loop with
   no desktop visible:
   ```
   sudo reboot
   ```

## Changing settings

Open `index.html` and edit the `CONFIG` object near the top of the script:

- `cycleSeconds`: how long each poster stays on screen before switching to
  the next one.
- `posterFolder`: the folder name the GIFs are served from. Leave this as
  `posters` unless you rename the folder.

## Adding Jellyfin later

The page and server already have placeholders for this:

- In `server.py`, the `/api/now-playing` endpoint currently always reports
  nothing playing. Replace the body of `handle_now_playing` with a real
  call to the Jellyfin API to get the current session and its poster image.
- In `index.html`, set `CONFIG.enableJellyfin = true`. The page will then
  poll `/api/now-playing` every `jellyfinPollSeconds` seconds and, if
  something is playing, replace the poster loop with that movie's poster
  until playback stops.

No changes to the systemd services or kiosk script are needed for this,
since it is all handled inside the existing page and server.
