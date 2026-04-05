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
        width = 22,
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
      -- Filesystem watcher configuration
      filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        max_events = 200,
        ignore_dirs = {
          'node_modules',
          '.git',
          'bin',
          'build',
          'dist',
          'target',
          '.cache',
          '.venv',
          'venv',
          '__pycache__',
          '/home/xonecas/src/zoea-nova/bin',
        },
      },
    })

  end,
}
