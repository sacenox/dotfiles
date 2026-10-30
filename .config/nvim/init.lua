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
      "zenbones-theme/zenbones.nvim",
      -- Optionally install Lush. Allows for more configuration or extending the colorscheme
      -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
      -- In Vim, compat mode is turned on as Lush only works in Neovim.
      dependencies = "rktjmp/lush.nvim",
      lazy = false,
      priority = 1000,
      -- you can set set configuration options here
      config = function()
        vim.cmd.colorscheme('neobones')
      end
    },

    -- Git signs
    {
      "lewis6991/gitsigns.nvim",
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

-- Statusline
local mode_groups = {
  { 'NORMAL', 'String' },
  { 'INSERT', 'Constant' },
  { 'VISUAL', 'Special' },
  { 'REPLACE', 'ErrorMsg' },
  { 'COMMAND', 'WarningMsg' },
  { 'TERMINAL', 'Title' },
}
local mode_keys = { n = 1, i = 2, v = 3, R = 4, c = 5, t = 6 }
local git_groups = {
  { 'StatusGitAdd', '+', 'DiffAdd DiagnosticOk String' },
  { 'StatusGitChange', '~', 'DiffChange DiagnosticWarn Constant' },
  { 'StatusGitDelete', '-', 'DiffDelete DiagnosticError ErrorMsg' },
}

local function apply_theme()
  local function fg(names)
    for name in names:gmatch('%S+') do
      local color = vim.api.nvim_get_hl(0, { name = name, link = false }).fg
      if color then return color end
    end
  end
  for _, m in ipairs(mode_groups) do
    local color = fg(m[2])
    if color then vim.api.nvim_set_hl(0, 'StatusMode' .. m[1], { fg = color, bold = true }) end
  end
  for _, g in ipairs(git_groups) do
    local color = fg(g[3])
    if color then vim.api.nvim_set_hl(0, g[1], { fg = color, bold = true }) end
  end
  local dir = fg('Directory')
  if dir then vim.api.nvim_set_hl(0, 'StatusFile', { fg = dir }) end
  -- match the statusline background to the Normal background
  local bg = vim.api.nvim_get_hl(0, { name = 'Normal', link = false }).bg
  for _, g in ipairs({ 'StatusLine', 'StatusLineNC' }) do
    local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
    hl.bg, hl.cterm, hl.ctermbg = bg, nil, nil
    vim.api.nvim_set_hl(0, g, hl)
  end
end

apply_theme()
vim.api.nvim_create_autocmd('ColorScheme', { callback = apply_theme })

local function git_info()
  local d = vim.b.gitsigns_status_dict
  if not (d and d.head) then return '' end
  local parts, counts = { ' ' .. d.head }, { d.added, d.changed, d.removed }
  for i, g in ipairs(git_groups) do
    if (counts[i] or 0) > 0 then
      parts[#parts + 1] = ('%%#%s#%s%d%%#StatusLine#'):format(g[1], g[2], counts[i])
    end
  end
  return table.concat(parts, ' ')
end

local function statusline()
  local m = vim.api.nvim_get_mode().mode:sub(1, 1)
  if m == '\22' or m == 'V' or m == 's' or m == 'S' then m = 'v' end
  local mode = mode_groups[mode_keys[m] or 1][1]
  return table.concat({
    '%#StatusMode' .. mode .. '# ' .. mode .. ' ',
    '%#StatusLine# %f%m%=',
    git_info(),
    ' %#StatusFile#' .. (vim.bo.filetype ~= '' and vim.bo.filetype or 'text'),
    '%#StatusLine# %p%% ',
  })
end

_G.Statusline = statusline
vim.o.statusline = '%!v:lua.Statusline()'
