-- diffview.nvim - Single tabpage interface for cycling through diffs
return {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('diffview').setup({
      diff_binaries = false,    -- Show diffs for binaries
      enhanced_diff_hl = true, -- Use nvim's builtin diff highlighting
      use_icons = true,         -- Requires nvim-web-devicons
      view = {
        -- Configure the layout and behavior of different types of views
        default = {
          layout = 'diff2_horizontal',
        },
      },
      file_panel = {
        listing_style = 'list',             -- 'list' or 'tree'
      },
      keymaps = {
        disable_defaults = false, -- Disable default keymaps
      },
    })

    -- Keybindings
    vim.keymap.set('n', '<leader>dv', '<CMD>DiffviewOpen<CR>', { desc = 'Open diffview' })
    vim.keymap.set('n', '<leader>dc', '<CMD>DiffviewClose<CR>', { desc = 'Close diffview' })
    vim.keymap.set('n', '<leader>dh', '<CMD>DiffviewFileHistory %<CR>', { desc = 'File history (current file)' })
    vim.keymap.set('n', '<leader>df', '<CMD>DiffviewFileHistory<CR>', { desc = 'File history (all files)' })
  end,
}
