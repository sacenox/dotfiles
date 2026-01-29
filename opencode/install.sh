#!/usr/bin/env bash
# Link opencode config files and directories into ~/.config/opencode, skipping existing targets.
set -e

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
commands_dir="$config_dir/commands"
skills_dir="$config_dir/skills"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$config_dir" "$commands_dir" "$skills_dir"

if [ ! -e "$config_dir/AGENTS.md" ] && [ ! -L "$config_dir/AGENTS.md" ]; then
  ln -s "$repo_dir/AGENTS.md" "$config_dir/AGENTS.md"
fi

shopt -s nullglob # Avoid literal glob patterns when directories are empty.
for item in "$repo_dir/commands"/*; do
  if [ -f "$item" ]; then
    target="$commands_dir/$(basename "$item")"
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
      ln -s "$item" "$target"
    fi
  fi
done

for item in "$repo_dir/skills"/*; do
  if [ -d "$item" ]; then
    target="$skills_dir/$(basename "$item")"
    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
      ln -s "$item" "$target"
    fi
  fi
done

echo "Linked opencode config to $config_dir"
