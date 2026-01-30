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
vim.opt.wildmode = 'list:longest,full'
vim.opt.wildignore = {
  '*.pyc',
  '*.o',
  '*.obj',
  '*.so',
  '*.swp',
  '*.zip',
  '*.exe',
  '*.dll',
  '*/.git/*',
  '*/.svn/*',
  '*/node_modules/*',
  '*/bower_components/*',
  '*/.DS_Store',
  '*/dist/*',
  '*/build/*',
  '*/target/*',
  '*/__pycache__/*',
  '*.egg-info',
}
vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '·', eol = '¬', nbsp = '_' }

-- Indentation settings
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

-- Statusline settings
vim.opt.showmode = false -- Don't show mode in command line (lualine shows it)

-- Set leader key to space (must be set before lazy.nvim)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require('lazy').setup('plugins', {
  change_detection = {
    notify = false, -- Don't notify on config changes
  },
})

-- Keymaps
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Search highlighting
keymap('n', '<leader>h', ':nohlsearch<CR>', opts)
keymap('n', '<leader>q', ':qall<CR>', { noremap = true, silent = true, desc = 'Quit all' })

-- LSP formatting
keymap('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true, desc = 'Format buffer with LSP' })

-- Movement remaps
keymap('n', 'j', 'gj', { noremap = true })
keymap('n', 'k', 'gk', { noremap = true })

-- File explorer (nvim-tree)
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle file explorer' })

-- Buffer navigation (bufferline)
keymap('n', '<leader>[', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })
keymap('n', '<leader>]', ':BufferLineCycleNext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })

-- Git (fugitive)
keymap('n', '<leader>d', ':Git ++curwin --paginate diff<CR>', { noremap = true, silent = true, desc = 'Git diff' })

-- Command aliases
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})

-- Colorscheme
vim.cmd.colorscheme('ansi')

-- Override diff highlight groups to remove backgrounds (keep only sign column indicators)
vim.api.nvim_set_hl(0, 'DiffAdd', { ctermbg = 'NONE', ctermfg = 'NONE' })
vim.api.nvim_set_hl(0, 'DiffChange', { ctermbg = 'NONE', ctermfg = 'NONE' })
vim.api.nvim_set_hl(0, 'DiffDelete', { ctermbg = 'NONE', ctermfg = 'NONE' })
vim.api.nvim_set_hl(0, 'DiffText', { ctermbg = 'NONE', ctermfg = 'NONE' })
