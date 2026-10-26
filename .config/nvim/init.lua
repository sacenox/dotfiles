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
    -- Theme
    {
      "nanotech/jellybeans.vim",
      lazy = false,
      priority = 1000,
    },

    -- Git signs
    {
      "lewis6991/gitsigns.nvim",
      opts = {},
    },

    -- Statusline
    {
      'nvim-mini/mini.statusline',
      version = false,
      opts = {},
    },

    -- Fuzzy Finder
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
      cmd = 'Telescope',
      opts = {
        defaults = {
          file_ignore_patterns = {
            '^%.git/',
            '^node_modules/',
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          },
        },
      },
    },

    -- Tree-sitter syntax highlighting
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      config = function()
        local parsers = {
          'bash',
          'css',
          'go',
          'html',
          'javascript',
          'json',
          'lua',
          'markdown',
          'markdown_inline',
          'python',
          'query',
          'tsx',
          'typescript',
          'vim',
          'vimdoc',
          'zig',
        }

        require('nvim-treesitter').install(parsers)

        vim.api.nvim_create_autocmd('FileType', {
          callback = function(args)
            pcall(vim.treesitter.start, args.buf)
          end,
        })
      end,
    },
  },

  -- Configure any other settings here. See the documentation for more details.
  -- disable automatic plugin update notifications on startup
  checker = { enabled = false },
})

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

-- Hide mode display and partial keybind. Reclaim the space.
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.cmdheight = 0

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
keymap('n', '<leader>Q', function()
  if vim.fn.winnr('$') > 1 then
    vim.cmd.close()
  else
    vim.cmd.bdelete()
  end
end, { noremap = true, silent = true, desc = 'Close focused buffer/split' })
keymap('n', '<leader>s', ':write<CR>', { noremap = true, silent = true, desc = 'Save buffer' })
keymap('n', '<leader>S', ':wall<CR>', { noremap = true, silent = true, desc = 'Save all buffers' })
keymap('n', '<leader>d', function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = 'Open diagnostics quickfix list' })

-- Plugin keybinds
keymap('n', '<leader>f', ':Telescope grep_string<CR>', opts)
keymap('n', '<leader>g', ':Telescope live_grep<CR>', opts)
keymap('n', '<leader>o', ':Telescope find_files<CR>', opts)
keymap('n', '<leader>b', ':Telescope buffers<CR>', opts)

-- Movement remaps
keymap('n', 'j', 'gj', { noremap = true })
keymap('n', 'k', 'gk', { noremap = true })

-- Command aliases
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})

vim.cmd.colorscheme("jellybeans")
