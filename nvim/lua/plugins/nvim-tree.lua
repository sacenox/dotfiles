-- nvim-tree.lua - File explorer tree
return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Disable netrw (nvim's default file explorer)
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require('nvim-tree').setup({
      -- Open tree on startup
      view = {
        width = 30,
        side = 'left',
      },
      -- Git integration
      git = {
        enable = true,
        ignore = false,
      },
      -- Show git status icons
      renderer = {
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
          glyphs = {
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      -- Automatically open on startup
      actions = {
        open_file = {
          quit_on_open = false,
        },
      },
    })

    -- Keybinding to toggle tree
    vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle file explorer' })

    -- Auto-open on startup
    local function open_nvim_tree()
      require('nvim-tree.api').tree.open()
    end
    vim.api.nvim_create_autocmd({ 'VimEnter' }, { callback = open_nvim_tree })
  end,
}
