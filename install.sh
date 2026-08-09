#!/bin/bash
# LobbyLoop install script.
#
# Downloads LobbyLoop from GitHub, installs the needed packages, sets
# permissions, installs the systemd services, and starts everything.
#
# Usage, on a fresh Raspberry Pi with nothing set up yet:
#   curl -fsSL https://raw.githubusercontent.com/rorpage/lobbyloop/main/install.sh | sudo bash
#
# If the repo's default branch is not "main", replace "main" in that URL
# with the correct branch name.
#
# You can also download this file and run it locally:
#   sudo bash install.sh

set -e

REPO_URL="https://github.com/rorpage/lobbyloop.git"
INSTALL_DIR="/home/pi/lobbyloop"
SERVICE_USER="pi"

echo "LobbyLoop install script"
echo "-------------------------"

# Check for root, since apt and systemctl need it.
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to run as root. Try: sudo bash install.sh"
  exit 1
fi

echo "Installing required packages (git, chromium-browser, unclutter)..."
apt update
apt install -y git chromium-browser unclutter

if [ -d "$INSTALL_DIR/.git" ]; then
  echo "$INSTALL_DIR already exists. Pulling the latest version..."
  cd "$INSTALL_DIR"
  sudo -u "$SERVICE_USER" git pull
elif [ -d "$INSTALL_DIR" ]; then
  echo "$INSTALL_DIR exists but is not a git repo. Leaving it as is."
  echo "Delete or rename that folder if you want a fresh clone instead."
else
  echo "Cloning LobbyLoop into $INSTALL_DIR..."
  sudo -u "$SERVICE_USER" git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo "Making kiosk.sh executable..."
chmod +x "$INSTALL_DIR/kiosk.sh"

echo "Making sure the posters folder exists..."
mkdir -p "$INSTALL_DIR/posters"
chown -R "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR"

echo "Installing systemd service files..."
cp "$INSTALL_DIR/lobbyloop-server.service" /etc/systemd/system/
cp "$INSTALL_DIR/lobbyloop-kiosk.service" /etc/systemd/system/

echo "Reloading systemd and enabling services..."
systemctl daemon-reload
systemctl enable lobbyloop-server.service
systemctl enable lobbyloop-kiosk.service

echo "Starting services..."
systemctl restart lobbyloop-server.service
systemctl restart lobbyloop-kiosk.service

echo ""
echo "Done. LobbyLoop should now be running and set to start on boot."
echo "If you don't see the poster loop on screen, check the service status with:"
echo "  systemctl status lobbyloop-server.service"
echo "  systemctl status lobbyloop-kiosk.service"
echo ""
echo "Add GIF files to $INSTALL_DIR/posters and they will show up on the next cycle."
