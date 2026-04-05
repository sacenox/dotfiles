-- LSP configuration with Mason for server management
return {
  -- Mason: LSP server installer
  {
    'williamboman/mason.nvim',
    config = function()
      local mason = require('mason')
      mason.setup({
        ui = {
          border = 'single',
          icons = {
            package_installed = '✓',
            package_pending = '➜',
            package_uninstalled = '✗'
          }
        }
      })
      
      -- Auto-install language servers and formatters if not present
      local mason_registry = require('mason-registry')
      local packages = { 'gopls', 'marksman', 'prettier' }
      
      for _, package in ipairs(packages) do
        if not mason_registry.is_installed(package) then
          vim.cmd('MasonInstall ' .. package)
        end
      end
      -- LSP keybindings (only active when LSP is attached)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf, noremap = true, silent = true }
          
          -- Navigation
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Show references' }))
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
          
          -- Actions
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
          
          -- Diagnostics
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
          vim.keymap.set('n', '<leader>,', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'Diagnostic list' }))
        end,
      })

      -- Default server capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Setup language servers using vim.lsp.config
      
      -- Go language server
      vim.lsp.config.gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.work', 'go.mod', '.git' },
        capabilities = capabilities,
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      }
      vim.lsp.enable('gopls')

      -- Markdown language server
      vim.lsp.config.marksman = {
        cmd = { 'marksman', 'server' },
        filetypes = { 'markdown', 'markdown.mdx' },
        root_markers = { '.git', '.marksman.toml' },
        capabilities = capabilities,
      }
      vim.lsp.enable('marksman')
      
      -- Example configurations (uncomment and modify as needed):
      
      -- vim.lsp.config.lua_ls = {
      --   cmd = { 'lua-language-server' },
      --   filetypes = { 'lua' },
      --   root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       diagnostics = {
      --         globals = { 'vim' },
      --       },
      --     },
      --   },
      -- }
      -- vim.lsp.enable('lua_ls')

      -- vim.lsp.config.ts_ls = {
      --   cmd = { 'typescript-language-server', '--stdio' },
      --   filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
      --   root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
      --   capabilities = capabilities,
      -- }
      -- vim.lsp.enable('ts_ls')

      -- vim.lsp.config.pyright = {
      --   cmd = { 'pyright-langserver', '--stdio' },
      --   filetypes = { 'python' },
      --   root_markers = { 'pyrightconfig.json', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
      --   capabilities = capabilities,
      -- }
      -- vim.lsp.enable('pyright')

      -- vim.lsp.config.rust_analyzer = {
      --   cmd = { 'rust-analyzer' },
      --   filetypes = { 'rust' },
      --   root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
      --   capabilities = capabilities,
      -- }
      -- vim.lsp.enable('rust_analyzer')
    end,
  }
}
