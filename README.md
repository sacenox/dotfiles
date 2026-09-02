# Dotfiles

Personal configuration files for my development environment.

Each folder is a config. Symlink it to the path the tool already discovers.

## Contents

- `nvim/` — Neovim → `~/.config/nvim`
- `ghostty/` — Ghostty → `~/.config/ghostty`
- `bash/` — Bash setup files
- `hunk/` — Hunk → `~/.config/hunk/config.toml`
- `hax/` — Hax agent, skills, prompts, helper scripts → `~/.config/hax`
- `pi/` — Pi agent, prompts, extensions → `~/.pi/agent`

## Usage

```sh
git clone git@github.com:sacenox/dotfiles.git ~/src/dotfiles

ln -s ~/src/dotfiles/nvim ~/.config/nvim
ln -s ~/src/dotfiles/ghostty ~/.config/ghostty
ln -s ~/src/dotfiles/hunk/config.toml ~/.config/hunk/config.toml

ln -s ~/src/dotfiles/hax ~/.config/hax
ln -s ~/src/dotfiles/hax/bin/hax-adversary ~/.local/bin/hax-adversary
ln -s ~/src/dotfiles/hax/bin/hax-loop ~/.local/bin/hax-loop

mkdir -p ~/.pi/agent/extensions ~/.agents
ln -s ~/src/dotfiles/pi/AGENTS.md ~/.agents/AGENTS.md
ln -s ~/.agents/AGENTS.md ~/.pi/agent/AGENTS.md
ln -s ~/src/dotfiles/pi/settings.json ~/.pi/agent/settings.json
ln -s ~/src/dotfiles/pi/prompts ~/.pi/agent/prompts
ln -s ~/src/dotfiles/pi/extensions/adversary ~/.pi/agent/extensions/adversary
ln -s ~/src/dotfiles/pi/extensions/exa ~/.pi/agent/extensions/exa
```
