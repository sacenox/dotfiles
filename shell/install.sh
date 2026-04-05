#!/usr/bin/env bash
# Install shell config by appending a source line to ~/.bashrc (or ~/.zshrc).
# The full bashrc is kept here for reference; the installer sources shared.sh
# so it works alongside an existing rc file.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

mkdir -p "$config_dir"

# Link shared.sh
target="$config_dir/shared.sh"
if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    ln -s "$repo_dir/shared.sh" "$target"
fi

source_line='[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shared.sh" ] && . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shared.sh"'

for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$rc_file" ]; then
        if ! grep -q "shell/shared.sh" "$rc_file"; then
            printf '\n# Load shared shell config\n%s\n' "$source_line" >> "$rc_file"
        fi
    fi
done

echo "Installed shell config."
echo "A full reference bashrc is in: $repo_dir/bashrc"
