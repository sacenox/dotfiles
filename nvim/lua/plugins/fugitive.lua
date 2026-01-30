-- vim-fugitive - Git integration
return {
  'tpope/vim-fugitive',
  config = function()
    -- Keybinding for git diff - opens in current buffer
    vim.keymap.set('n', '<leader>d', ':Git ++curwin --paginate diff<CR>', { noremap = true, silent = true, desc = 'Git diff' })
  end,
}
