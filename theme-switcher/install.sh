#!/usr/bin/env bash
# Install the KDE ↔ Alacritty/pi theme switcher.
# Puts the script in ~/.local/bin and enables a systemd user service.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="$HOME/.local/bin"
service_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

mkdir -p "$bin_dir" "$service_dir"

# Install the watcher script
target="$bin_dir/alacritty-theme-switcher"
if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Removing old script: $target"
    rm -f "$target"
fi
ln -s "$repo_dir/alacritty-theme-switcher" "$target"
chmod +x "$target"
echo "Linked script -> $target"

# Install the systemd service
svc="$service_dir/alacritty-theme-switcher.service"
if [ -e "$svc" ] || [ -L "$svc" ]; then
    echo "Removing old service: $svc"
    rm -f "$svc"
fi
ln -s "$repo_dir/alacritty-theme-switcher.service" "$svc"
echo "Linked service -> $svc"

# Enable and start
systemctl --user daemon-reload
systemctl --user enable --now alacritty-theme-switcher.service
echo "Theme switcher installed and running."
