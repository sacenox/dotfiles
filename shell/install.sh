#!/usr/bin/env bash
# Link shared shell config and source it from existing shell rc files.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
shared_target="$config_dir/shared.sh"

mkdir -p "$config_dir"

if [ ! -e "$shared_target" ] && [ ! -L "$shared_target" ]; then
  ln -s "$repo_dir/shared.sh" "$shared_target"
fi

# Use POSIX-compatible '.' instead of 'source'; bash/zsh are not strictly POSIX by default.
source_line='[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shared.sh" ] && . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shared.sh"'

for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
  if [ -f "$rc_file" ]; then
    if ! grep -q "shell/shared.sh" "$rc_file"; then
      printf '\n# Load shared shell config\n%s\n' "$source_line" >> "$rc_file"
    fi
  fi
done

echo "Installed shared shell config to $shared_target"
echo "Note: install dependencies (fortune, cowsay, lolcat) if you haven't yet."
