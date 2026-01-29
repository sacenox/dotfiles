# dotfiles

Personal configuration files for development tools and environments.

## Overview

This repository contains my personal configuration files (dotfiles) for various development tools. These configurations are tailored to my workflow and preferences.

## Contents

### Neovim Configuration

Location: `nvim/`

My Neovim setup with custom keybindings, plugins, and color schemes.

- **init.lua** - Main configuration file
- **lua/plugins/** - Plugin configurations using lazy.nvim
- **colors/** - Custom color schemes
- **KEYBINDINGS.md** - Documentation of custom keybindings
- **README.md** - Detailed Neovim setup documentation

### OpenCode Configuration

Location: `opencode/`

Configuration for the OpenCode AI coding assistant.

- **AGENTS.md** - Agent behavior and instructions
- **commands/** - Custom slash commands
- **skills/** - Reusable skills for specific tasks

## Installation

To use these configurations, symlink the desired config directories to their expected locations:

```bash
# Neovim
ln -s /path/to/dotfiles/nvim ~/.config/nvim

# OpenCode
ln -s /path/to/dotfiles/opencode ~/.config/opencode
```

## Requirements

- Neovim >= 0.9.0
- OpenCode CLI tool
