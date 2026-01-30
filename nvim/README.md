# Neovim Configuration

Modern Neovim configuration using Lua and lazy.nvim plugin manager.

## Structure

```
~/.config/nvim/
├── init.lua              # Main configuration file
├── lua/
│   └── plugins/          # Plugin configurations
│       ├── nvim-tree.lua # File explorer
│       ├── bufferline.lua # Buffer tabs
│       ├── fugitive.lua  # Git commands
│       ├── lsp.lua       # LSP configuration with Mason
│       ├── gitsigns.lua  # Git decorations
│       ├── comment.lua   # Comment toggling
│       └── lualine.lua   # Statusline
├── colors/
│   └── ansi.vim         # Colorscheme
└── README.md            # This file
```

## Plugins

### File Management
- **nvim-tree.lua** - Tree-based file explorer. Press `<leader>e` to toggle.

### Buffer Tabs
- **bufferline.nvim** - VSCode-style buffer tabs with mouse support.

### Language Server Protocol (LSP)
- **nvim-lspconfig** - LSP client configuration for Neovim
- **mason.nvim** - Package manager for LSP servers, DAP servers, linters, and formatters
- **mason-lspconfig.nvim** - Bridge between mason.nvim and nvim-lspconfig

### Git Integration
- **vim-fugitive** - Git commands inside Neovim (`:Git`, `:Git diff`).
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
    Press <leader>e
    ```

6. Try commenting:
   ```
   Press gcc        (toggle comment on line)
   Press gc + motion (comment with motion, e.g., gcap)
   ```

7. Try git integration (in a git repo):
    ```
    Press <leader>d  (git diff via fugitive)
    Press ]c         (next git change)
    Press [c         (previous git change)
    ```

## Key Features

- **Leader key**: `Space`
- **LSP support**: Language server protocol with Mason package manager for easy server installation
- **File explorer**: Tree-based with nvim-tree (`<leader>e`)
- **Buffer tabs**: Visual buffer list with bufferline.nvim
- **Git commands**: Fugitive for `:Git` workflow and quick diffs
- **Git decorations**: Inline change markers with gitsigns.nvim
- **Terminal colors**: Uses the `ansi` colorscheme and 16-color theme for lualine, respecting your terminal's color palette
- **Clean config**: Only essential options, modern Lua syntax
- **No clutter**: Swap files, backups disabled

## Configuration Philosophy

- Minimal and focused - only includes what's needed
- Modern Neovim defaults - removes redundant settings
- Tree-based navigation - nvim-tree with bufferline tabs
- Git-first - excellent git integration out of the box

## Customization

- Edit plugin configurations in `lua/plugins/*.lua`
- Global keybindings are in `init.lua`
- Plugin-specific keybindings are in each plugin's config file under `lua/plugins/`

## Resources

- [lazy.nvim docs](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig docs](https://github.com/neovim/nvim-lspconfig)
- [mason.nvim docs](https://github.com/williamboman/mason.nvim)
- [nvim-tree docs](https://github.com/nvim-tree/nvim-tree.lua)
- [bufferline.nvim docs](https://github.com/akinsho/bufferline.nvim)
- [vim-fugitive docs](https://github.com/tpope/vim-fugitive)
- [gitsigns.nvim docs](https://github.com/lewis6991/gitsigns.nvim)
- [Comment.nvim docs](https://github.com/numToStr/Comment.nvim)
- [lualine.nvim docs](https://github.com/nvim-lualine/lualine.nvim)
