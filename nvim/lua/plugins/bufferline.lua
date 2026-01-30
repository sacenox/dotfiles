-- bufferline.nvim - VSCode-like buffer tabs
return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('bufferline').setup({
      options = {
        -- Mouse support for clicking tabs
        mode = 'buffers',
        numbers = 'none',
        close_command = 'bdelete! %d',
        right_mouse_command = 'bdelete! %d',
        left_mouse_command = 'buffer %d',
        middle_mouse_command = nil,
        -- Show close button on tabs
        show_buffer_close_icons = true,
        show_close_icon = false,
        -- Show modified indicator
        modified_icon = '●',
        -- Show icons
        show_buffer_icons = true,
        -- Tab appearance
        separator_style = 'thin',
        always_show_bufferline = true,
        -- Integration with nvim-tree
        offsets = {
          {
            filetype = 'NvimTree',
            text = 'File Explorer',
            text_align = 'left',
            separator = true,
          },
        },
      },
      -- ANSI color theme (matches colors/ansi.vim)
      highlights = {
        -- Background fill
        fill = {
          ctermbg = 'NONE',
        },
        -- Inactive buffers (not visible)
        background = {
          ctermfg = 7,
          ctermbg = 0,
        },
        -- Visible buffers (visible but not selected)
        buffer_visible = {
          ctermfg = 15,
          ctermbg = 8,
        },
        -- Selected buffer
        buffer_selected = {
          ctermfg = 0,
          ctermbg = 11,
        },
        -- Modified indicator
        modified = {
          ctermfg = 7,
          ctermbg = 0,
        },
        modified_visible = {
          ctermfg = 15,
          ctermbg = 8,
        },
        modified_selected = {
          ctermfg = 0,
          ctermbg = 11,
        },
        -- Separators
        separator = {
          ctermfg = 8,
          ctermbg = 0,
        },
        separator_visible = {
          ctermfg = 8,
          ctermbg = 8,
        },
        separator_selected = {
          ctermfg = 8,
          ctermbg = 11,
        },
        -- Close buttons
        close_button = {
          ctermfg = 7,
          ctermbg = 0,
        },
        close_button_visible = {
          ctermfg = 15,
          ctermbg = 8,
        },
        close_button_selected = {
          ctermfg = 0,
          ctermbg = 11,
        },
      },
    })
  end,
}
