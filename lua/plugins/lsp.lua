local lsp = {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },

  config = function()
    local lspconfig = require('lspconfig')

    lspconfig.lua_ls.setup {}

    lspconfig.pyright.setup {
      settings = {
        analysis = {
          autoImportCompletions = true
        },
      },
    }

    lspconfig.gopls.setup {
      settings = {
        completion = {
          completeUnimported = true, -- Show unimported packages in completion
        },
      }
    }

    lspconfig.clangd.setup {}

    -- Format on :w
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        if client.supports_method('textDocument/implementation') then
          -- Create a keymap for vim.lsp.buf.implementation
          vim.api.nvim_create_autocmd('BufWritePre', {
            buffer = args.buf,
            callback = function()
              vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
            end,
          })
        end
      end,
    })
  end
}

return { lsp }
