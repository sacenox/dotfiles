# dotfiles

Personal configs for a KDE Plasma 6 + Alacritty + Neovim setup on CachyOS (Arch).

Everything uses the [0x96f](https://github.com/0x96f-org/) color palette, with
coordinated dark/light switching that follows KDE's sunrise/sunset schedule.

## What's in here

```
alacritty/          Alacritty terminal config + 0x96f dark/light themes
codium/             VSCodium settings + extensions list
nvim/               Neovim config (lazy.nvim, LSP, fzf-lua, ANSI color scheme)
pi/                 pi coding agent themes (0x96f-dark, 0x96f-light)
shell/              Bash config — aliases, prompt with exit status & timer, git info
theme-switcher/     D-Bus watcher that syncs all tools with KDE dark/light mode
```

## Installation

```bash
# Everything
./install.sh

# Specific configs
./install.sh nvim
./install.sh alacritty theme-switcher pi
```

Each config either symlinks into `~/.config/` or runs its own `install.sh` for
custom placement.

## Color Coordination

All tools share the same 0x96f palette. The theme switcher daemon keeps
everything in sync when KDE toggles between dark and light mode:

```
KDE sunrise/sunset toggle
  → D-Bus signal (org.freedesktop.appearance)
    → alacritty-theme-switcher
      ├─ Alacritty   cp dark.toml/light.toml → current-theme.toml  (live reload)
      ├─ pi          jq .theme → settings.json                     (next session)
      ├─ Neovim      writes ~/.local/state/kde-color-mode           (<leader>T toggle)
      ├─ VSCodium    built-in window.autoDetectColorScheme          (automatic)
      └─ (extensible — anything can read the signal file)
```

### Neovim specifics

The `ansi.vim` colorscheme uses **cterm ANSI indices only** (`set notermguicolors`),
so nvim inherits its colors directly from the terminal. When Alacritty's theme
changes, nvim gets new colors immediately. The `theme-sync.lua` plugin polls a
signal file to flip `background=dark/light`, which re-sources the colorscheme
to adjust UI elements (status line, cursor line, popups, etc.) that need
different treatment on light vs dark backgrounds.

## Details

### Shell (`shell/`)

Full reference bashrc is in `shell/bashrc`. Key features:

- **Two-line prompt**: `HH:MM:SS exit_code duration ~/path (branch*)`  on the
  first line, `$ ` on the second.
- **Command timer**: uses a `DEBUG` trap + `$SECONDS` — pure bash, no
  external dependencies.
- **Git branch + dirty flag** in the prompt.
- `greet` function: random cowsay + fortune + lolcat on shell start.
- fzf integration, aliases for git/nvim.

### Alacritty (`alacritty/`)

- Config with `live_config_reload = true`.
- Colors live in a separate `current-theme.toml` imported via Alacritty's
  `import` directive — the theme switcher writes this file.
- Two themes based on the [0x96f palette](https://github.com/0x96f-org/0x96f-term-theme):
  - `themes/dark.toml` — dark background (`#262427`)
  - `themes/light.toml` — light complement (`#fafafa`)

### Pi (`pi/`)

Custom themes for the [pi](https://github.com/badlogic/pi-mono) coding agent:

- `0x96f-dark.json` — mapped from the dark palette
- `0x96f-light.json` — mapped from the light palette

Both use the same semantic mapping: cyan for accents, blue for borders,
magenta for keywords, green for strings, yellow for headings/types.

### Theme Switcher (`theme-switcher/`)

A bash script + systemd user service that watches KDE's dark/light mode via
D-Bus (`org.freedesktop.portal.Settings`).

**Dependencies:** `dbus-monitor` (usually pre-installed), `jq` (for pi
settings; gracefully skipped if absent).

**Service management:**

```bash
systemctl --user status alacritty-theme-switcher
journalctl --user -u alacritty-theme-switcher -f
```

### VSCodium (`codium/`)

- Settings with `window.autoDetectColorScheme` for automatic dark/light switching.
- `preferredDarkColorTheme`: **0x96f** (from marketplace).
- `preferredLightColorTheme`: **0x96f Light** (custom, built in `~/src/0x96f-light-codium-theme`).
- `extensions.txt` — list of installed extensions for reproducible setup.

### Neovim (`nvim/`)

See [`nvim/README.md`](nvim/README.md) for details.

## Requirements

- Bash 4+
- Neovim ≥ 0.9
- Alacritty ≥ 0.13 (for `import` support)
- KDE Plasma 6 (for the theme switcher D-Bus integration)
- Optional: `fortune`, `cowsay`, `lolcat` (shell greeting)
- Optional: `jq` (pi theme switching)
