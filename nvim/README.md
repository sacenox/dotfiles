# Neovim Configuration

Modern Neovim configuration using Lua and lazy.nvim plugin manager.

## Structure

```
~/.config/nvim/
├── init.lua              # Main configuration file
├── lua/
│   └── plugins/          # Plugin configurations
│       ├── oil.lua       # File explorer
│       ├── lsp.lua       # LSP configuration with Mason
│       ├── diffview.lua  # Git diff viewer
│       ├── gitsigns.lua  # Git decorations
│       ├── comment.lua   # Comment toggling
│       └── lualine.lua   # Statusline
├── colors/
│   └── ansi.vim         # Colorscheme
└── README.md            # This file
```

## Plugins

### File Management
- **oil.nvim** - Edit your filesystem like a buffer. Press `-` or `<Space>n` to open.

### Language Server Protocol (LSP)
- **nvim-lspconfig** - LSP client configuration for Neovim
- **mason.nvim** - Package manager for LSP servers, DAP servers, linters, and formatters
- **mason-lspconfig.nvim** - Bridge between mason.nvim and nvim-lspconfig

### Git Integration
- **diffview.nvim** - Review git changes, commits, and file history with ease.
- **gitsigns.nvim** - Inline git decorations showing added/changed/deleted lines in the sign column.

### Editing
- **Comment.nvim** - Smart commenting with treesitter support. Press `gcc` to toggle line comment.

### UI
- **lualine.nvim** - Fast statusline with git branch, diff stats, and diagnostics.

## Getting Started

1. Open Neovim - plugins will automatically install on first run:
   ```bash
   nvim
   ```

2. Wait for lazy.nvim to install all plugins (happens automatically)

3. Check plugin status:
   ```
   :Lazy
   ```

4. Install LSP servers (optional):
   ```
   :Mason
   ```

5. Try the file explorer:
   ```
   Press <Space>n or -
   ```

6. Try commenting:
   ```
   Press gcc        (toggle comment on line)
   Press gc + motion (comment with motion, e.g., gcap)
   ```

7. Try git integration (in a git repo):
   ```
   Press <Space>dv  (open diffview)
   Press ]c         (next git change)
   ```

## Key Features

- **Leader key**: `Space`
- **LSP support**: Language server protocol with Mason package manager for easy server installation
- **File explorer**: Buffer-based with oil.nvim (edit filesystem like text)
- **Git diff viewer**: Comprehensive diff interface with diffview.nvim
- **Git decorations**: Inline change markers with gitsigns.nvim
- **Terminal colors**: Uses the `ansi` colorscheme and 16-color theme for lualine, respecting your terminal's color palette
- **Clean config**: Only essential options, modern Lua syntax
- **No clutter**: Swap files, backups disabled

## Configuration Philosophy

- Minimal and focused - only includes what's needed
- Modern Neovim defaults - removes redundant settings
- Buffer-centric workflow - oil.nvim instead of traditional tree explorer
- Git-first - excellent git integration out of the box

## Customization

- Edit plugin configurations in `lua/plugins/*.lua`
- Global keybindings are in `init.lua`
- Plugin-specific keybindings are in each plugin's config file under `lua/plugins/`

## Resources

- [lazy.nvim docs](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig docs](https://github.com/neovim/nvim-lspconfig)
- [mason.nvim docs](https://github.com/williamboman/mason.nvim)
- [oil.nvim docs](https://github.com/stevearc/oil.nvim)
- [diffview.nvim docs](https://github.com/sindrets/diffview.nvim)
- [gitsigns.nvim docs](https://github.com/lewis6991/gitsigns.nvim)
- [Comment.nvim docs](https://github.com/numToStr/Comment.nvim)
- [lualine.nvim docs](https://github.com/nvim-lualine/lualine.nvim)
