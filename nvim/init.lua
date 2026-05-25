-- Neovim configuration

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

-- Keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- My keybindings
keymap('n', '<leader>h', ':nohlsearch<CR>', opts)
keymap('n', '<leader>q', ':qall<CR>', { noremap = true, silent = true, desc = 'Quit all' })
keymap('n', '<leader>s', ':write<CR>', { noremap = true, silent = true, desc = 'Save buffer' })
keymap('n', '<leader>S', ':wall<CR>', { noremap = true, silent = true, desc = 'Save all buffers' })
keymap('n', '<leader>e', ':e .', { noremap = true, silent = true, desc = 'Save all buffers' })

-- Movement remaps
keymap('n', 'j', 'gj', { noremap = true })
keymap('n', 'k', 'gk', { noremap = true })

-- Command aliases
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})

-- Theme
vim.cmd('colorscheme sorbet')
