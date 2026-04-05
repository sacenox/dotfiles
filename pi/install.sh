#!/usr/bin/env bash
# Install pi coding agent themes.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme_dir="$HOME/.pi/agent/themes"

mkdir -p "$theme_dir"

for f in "$repo_dir"/themes/*.json; do
    name="$(basename "$f")"
    target="$theme_dir/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Skipping $name (already exists): $target"
    else
        ln -s "$f" "$target"
        echo "Linked $name -> $target"
    fi
done

echo "Pi themes installed. Select via /settings or settings.json."
