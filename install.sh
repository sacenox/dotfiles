#!/usr/bin/env bash
# Install configs from this repo.
# Usage: ./install.sh [config ...]
#   No args installs all configs.
#   Available configs: alacritty, nvim, shell, theme-switcher
#
# If a config has its own install.sh, it is executed instead of linked.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"

configs=()
if [ "$#" -gt 0 ]; then
    configs=("$@")
else
    shopt -s nullglob
    for dir in "$repo_dir"/*; do
        if [ -d "$dir" ]; then
            configs+=("$(basename "$dir")")
        fi
    done
fi

for config in "${configs[@]}"; do
    config_dir="$repo_dir/$config"
    if [ ! -d "$config_dir" ]; then
        echo "Unknown config: $config" >&2
        exit 1
    fi

    echo "==> Installing $config"

    if [ -f "$config_dir/install.sh" ]; then
        bash "$config_dir/install.sh"
        continue
    fi

    mkdir -p "$config_root"
    target="$config_root/$config"
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "  Skipping (target exists): $target"
        continue
    fi

    ln -s "$config_dir" "$target"
    echo "  Linked $config -> $target"
done
