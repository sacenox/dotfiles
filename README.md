# Dotfiles

Personal configuration files for my development environment.

Each folder is a config. Symlink it to the path the tool already discovers.

## Contents

- `agents/` — Agents → `~/.agents`
- `bash/` — Bash → `~/.bashrc`
- `ghostty/` — Ghostty → `~/.config/ghostty/config`
- `kitty/` — Kitty → `~/.config/kitty`
- `mini-coding-agent/` — mini-coding-agent → `~/.config/mini-coding-agent`
- `nvim/` — Neovim → `~/.config/nvim`

## Usage

```sh
git clone git@github.com:sacenox/dotfiles.git ~/src/dotfiles
```

Then symlink your desired configs to their respective place (some in `~/.config`, others in `~`).

Review each directory before using, as these files are tailored to my personal workflow.
