# dotfiles

Personal configuration files for development tools and environments.

## Overview

This repository contains my personal configuration files (dotfiles) for various development tools. These configurations are tailored to my workflow and preferences.

## Contents

### Neovim Configuration

Location: `nvim/`

Modern Neovim setup using Lua and lazy.nvim plugin manager with LSP support, git integration, and a buffer-based file explorer.

- **init.lua** - Main configuration file with basic settings and keybindings
- **lua/plugins/** - Plugin configurations (oil, LSP with Mason, gitsigns, diffview, lualine, comment)
- **colors/ansi.vim** - Terminal-respecting 16-color ANSI colorscheme
- **README.md** - Detailed Neovim setup documentation

**Key Features:**
- Leader key: Space
- Buffer-centric workflow with oil.nvim
- LSP support with Mason installer
- Git integration (gitsigns + diffview)
- Minimal, focused configuration

### OpenCode Configuration

Location: `opencode/`

Configuration for the OpenCode AI coding assistant with custom behaviors, commands, and reusable skills.

- **AGENTS.md** - Core agent behavior and debugging principles
- **commands/** - Custom slash commands (commit-all, format-then-lint)
- **skills/** - Reusable skills (good-programming-principles, token-efficiency-opencode)

**Key Principles:**
- Never lie, deceive, or omit information
- Always find root cause before fixing issues
- Apply KISS, DRY, YAGNI, SOLID principles
- Minimize token usage

### Shell Configuration

Location: `shell/`

Shared shell configuration for bash and zsh with aliases and functions.

- **shared.sh** - Common shell aliases, environment variables, and functions
- **install.sh** - Installation script that symlinks config and sources it in shell rc files

**Features:**
- Git aliases (g, gst, gc, gp, gpo)
- File listing aliases (ll, ls with color)
- Editor setup (EDITOR=nvim)
- Fun greeting function using fortune, cowsay, and lolcat

## Installation

The repository includes a master installation script that can install all configs or specific ones.

### Install Everything

```bash
cd /path/to/dotfiles
./install.sh
```

### Install Specific Configs

```bash
./install.sh nvim          # Only Neovim
./install.sh opencode      # Only OpenCode
./install.sh shell         # Only Shell config
./install.sh nvim shell    # Multiple specific configs
```

### Manual Symlinks

Alternatively, symlink the desired config directories to their expected locations:

```bash
# Neovim
ln -s /path/to/dotfiles/nvim ~/.config/nvim

# OpenCode
ln -s /path/to/dotfiles/opencode ~/.config/opencode

# Shell (or use shell/install.sh for automatic shell rc integration)
ln -s /path/to/dotfiles/shell ~/.config/shell
```

## Requirements

### Core Requirements
- Neovim >= 0.9.0
- Git
- OpenCode CLI tool

### Optional Dependencies
- fortune, cowsay, lolcat (for shell greeting function)

## Post-Installation

1. **Neovim**: Open nvim - plugins will auto-install via lazy.nvim on first run
2. **Shell**: Restart your shell to load new aliases and functions
3. **LSP Servers**: Install LSP servers via `:Mason` in Neovim if needed
