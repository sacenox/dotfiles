#!/usr/bin/env bash
# Install Alacritty config and themes.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"

mkdir -p "$config_dir/themes"

# Link main config
for f in alacritty.toml; do
    target="$config_dir/$f"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Skipping $f (already exists): $target"
    else
        ln -s "$repo_dir/$f" "$target"
        echo "Linked $f -> $target"
    fi
done

# Link theme files
for f in "$repo_dir"/themes/*.toml; do
    name="$(basename "$f")"
    target="$config_dir/themes/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Skipping themes/$name (already exists): $target"
    else
        ln -s "$f" "$target"
        echo "Linked themes/$name -> $target"
    fi
done

# Initialize current-theme.toml with dark if it doesn't exist
if [ ! -e "$config_dir/current-theme.toml" ]; then
    cp "$repo_dir/themes/dark.toml" "$config_dir/current-theme.toml"
    echo "Initialized current-theme.toml (dark)"
fi

echo "Alacritty config installed."
