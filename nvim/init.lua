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
keymap('n', '<leader>s', ':write<CR>', { noremap = true, silent = true, desc = 'Save buffer' })
keymap('n', '<leader>S', ':wall<CR>', { noremap = true, silent = true, desc = 'Save all buffers' })

-- LSP formatting
keymap('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { noremap = true, silent = true, desc = 'Format with LSP' })

-- Prettier formatting
keymap('n', '<leader>F', function()
  local prettier_path = vim.fn.stdpath('data') .. '/mason/bin/prettier'
  if vim.fn.executable(prettier_path) == 1 then
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local content = table.concat(lines, '\n')
    
    vim.fn.jobstart({ prettier_path, '--stdin-filepath', vim.api.nvim_buf_get_name(bufnr) }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.schedule(function()
            local formatted = table.concat(data, '\n'):gsub('\n$', '')
            local new_lines = vim.split(formatted, '\n')
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
            print('Formatted with prettier')
          end)
        end
      end,
      stdin = content,
    })
  else
    print('Prettier not found. Run :Mason to install it.')
  end
end, { noremap = true, silent = false, desc = 'Format with Prettier' })

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
