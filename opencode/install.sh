#!/usr/bin/env bash
# Link opencode config files and directories into ~/.config/opencode, refreshing existing targets.
set -e

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
commands_dir="$config_dir/commands"
skills_dir="$config_dir/skills"
agents_dir="$config_dir/agents"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$config_dir" "$commands_dir" "$skills_dir" "$agents_dir"

ln -sf "$repo_dir/opencode.json" "$config_dir/opencode.json"
ln -sf "$repo_dir/AGENTS.md" "$config_dir/AGENTS.md"
ln -sfn "$repo_dir/.agent-docs" "$config_dir/.agent-docs"

shopt -s nullglob # Avoid literal glob patterns when directories are empty.
for item in "$repo_dir/commands"/*; do
  if [ -f "$item" ]; then
    target="$commands_dir/$(basename "$item")"
    ln -sf "$item" "$target"
  fi
done

for item in "$repo_dir/skills"/*; do
  if [ -d "$item" ]; then
    target="$skills_dir/$(basename "$item")"
    ln -sfn "$item" "$target"
  fi
done

for item in "$repo_dir/agents"/*; do
  if [ -f "$item" ]; then
    target="$agents_dir/$(basename "$item")"
    ln -sf "$item" "$target"
  fi
done

echo "Linked opencode config to $config_dir"
