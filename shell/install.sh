#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp "$script_dir/bashrc" "$HOME/.bashrc"
echo "Installed $script_dir/bashrc -> $HOME/.bashrc"
