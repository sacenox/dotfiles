# dotfiles

Personal configuration files for development tools and environments.

## Overview

This repository contains my personal configuration files (dotfiles) for various development tools. These configurations are tailored to my workflow and preferences.

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
