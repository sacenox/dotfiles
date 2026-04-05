#!/usr/bin/env bash
# Install VSCodium settings and extensions.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/VSCodium/User"

mkdir -p "$config_dir"

# Link settings
target="$config_dir/settings.json"
if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Skipping settings.json (already exists): $target"
else
    ln -s "$repo_dir/settings.json" "$target"
    echo "Linked settings.json -> $target"
fi

# Install extensions
if command -v codium >/dev/null 2>&1; then
    while IFS= read -r ext; do
        [ -z "$ext" ] && continue
        codium --install-extension "$ext" --force 2>/dev/null && \
            echo "Installed $ext" || echo "Failed: $ext"
    done < "$repo_dir/extensions.txt"
else
    echo "codium not found, skipping extension install."
fi

# Install 0x96f-light theme from local source if available
local_theme="$HOME/src/0x96f-light-codium-theme"
if [ -d "$local_theme" ] && command -v codium >/dev/null 2>&1; then
    vsix=$(find "$local_theme" -maxdepth 1 -name "*.vsix" | head -1)
    if [ -n "$vsix" ]; then
        codium --install-extension "$vsix" && echo "Installed 0x96f-light from VSIX"
    fi
fi

echo "VSCodium config installed."
