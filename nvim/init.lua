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
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          theme = 'auto',
        },
      },
    },

    -- Git signs
    {
      "lewis6991/gitsigns.nvim",
      opts = {},
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
        require("nvim-tree").setup {
          filters = {
            git_ignored = false,
          },
        }
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

    -- LSP/etc with Mason
    {
      "neovim/nvim-lspconfig",
      config = function()
        local function executable(path)
          return path and vim.fn.executable(path) == 1
        end

        local function join(...)
          return table.concat({ ... }, "/")
        end

        local function project_python(root_dir)
          if root_dir then
            for _, venv_name in ipairs({ ".venv", "venv" }) do
              local python = join(root_dir, venv_name, "bin", "python")
              if executable(python) then
                return python
              end
            end
          end

          if vim.env.VIRTUAL_ENV then
            local python = join(vim.env.VIRTUAL_ENV, "bin", "python")
            if executable(python) then
              return python
            end
          end

          local python3 = vim.fn.exepath("python3")
          if python3 ~= "" then
            return python3
          end

          local python = vim.fn.exepath("python")
          if python ~= "" then
            return python
          end
        end

        vim.lsp.config("pyright", {
          before_init = function(_, config)
            local python = project_python(config.root_dir)
            if not python then
              return
            end

            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python

            config.settings.python.analysis = config.settings.python.analysis or {}
            config.settings.python.analysis.autoSearchPaths = true
            config.settings.python.analysis.useLibraryCodeForTypes = true

            local src_path = config.root_dir and join(config.root_dir, "src") or nil
            if src_path and vim.fn.isdirectory(src_path) == 1 then
              config.settings.python.analysis.extraPaths = { src_path }
            end
          end,
        })
      end,
    },
    {
      "mason-org/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },
    {
      "mason-org/mason-lspconfig.nvim",
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = {
            "biome",
            "emmylua_ls",
            "gopls",
            "pyright",
            "ruff",
            "ts_ls",
            "zls",
          },
          automatic_enable = true,
        })
      end,
    },

    -- Use vim-ai-complete for autocomplete
    {
      dir = "/home/xonecas/src/vim-ai-complete",
      name = "vim-ai-complete",
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- disable automatic plugin update notifications on startup
  checker = { enabled = false },
})

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
keymap('n', '<leader>e', ':NvimTreeToggle<CR>', opts)
keymap('n', '<leader>f', ':Telescope find_files<CR>', opts)

-- Movement remaps
keymap('n', 'j', 'gj', { noremap = true })
keymap('n', 'k', 'gk', { noremap = true })

-- Command aliases
vim.api.nvim_create_user_command('Q', 'q', {})
vim.api.nvim_create_user_command('W', 'w', {})

-- Shortcut to open the inline AI prompt in visual mode
keymap('x', '<leader>a', ':Ai<CR>', opts)

-- Set a nice theme?
vim.cmd.colorscheme('retrobox')
