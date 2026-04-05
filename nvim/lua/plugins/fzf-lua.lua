-- fzf-lua - Fuzzy file and content finder
return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    {
      '<leader>p',
      function()
        require('fzf-lua').files({ gitignore = true })
      end,
      desc = 'Find files (fuzzy path)',
    },
  },
  config = function()
    require('fzf-lua').setup({
      files = {
        gitignore = true,
      },
    })
  end,
}
