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
```

Then symlink your desired configs to their respective place (some in `~/.config`, others in `~`).

Review each directory before using, as these files are tailored to my personal workflow.
