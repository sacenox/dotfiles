-- Neovim configuration
-- Author: @xonecas
-- Version: 0.1.1

-- Basic settings
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.cinkeys:remove('0#') -- Prevent auto-unindenting lines that start with '#' (for Python comments, preprocessor directives)
vim.opt.linebreak = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.termguicolors = true

-- Indentation settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Set leader key to space (must be set before lazy.nvim)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    {
      -- Theme:
      "zenbones-theme/zenbones.nvim",
      -- Optionally install Lush. Allows for more configuration or extending the colorscheme
      -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
      -- In Vim, compat mode is turned on as Lush only works in Neovim.
      dependencies = "rktjmp/lush.nvim",
      lazy = false,
      priority = 1000,
      -- you can set set configuration options here
      config = function()
        -- vim.g.zenbones_darken_comments = 45
        vim.cmd.colorscheme('randombones')
      end
    },

    -- File tree sidebar
    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = {
        "nvim-tree/nvim-web-devicons",
      },
      config = function()
        require("nvim-tree").setup {}
      end,
    },

    -- Fuzzy Finder
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
      cmd = 'Telescope',
    },

    -- Use `pi` for autocomplete
    {
      "sacenox/vim-pi-complete",
      cmd = { "Pi" },
    }
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- Keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- My keybindings
keymap('n', '<leader>h', ':nohlsearch<CR>', opts)
keymap('n', '<leader>q', ':qall<CR>', { noremap = true, silent = true, desc = 'Quit all' })
keymap('n', '<leader>s', ':write<CR>', { noremap = true, silent = true, desc = 'Save buffer' })
keymap('n', '<leader>S', ':wall<CR>', { noremap = true, silent = true, desc = 'Save all buffers' })

-- Plugin keybinds
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
keymap('n', '<leader>f', ':Telescope find_files<CR>', opts)

-- Movement remaps
keymap('n', 'j', 'gj', { noremap = true })
keymap('n', 'k', 'gk', { noremap = true })

-- Command aliases
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})
