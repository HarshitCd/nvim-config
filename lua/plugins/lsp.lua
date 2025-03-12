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
    {
      "jose-elias-alvarez/null-ls.nvim",
      config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            -- ESLint for linting
            null_ls.builtins.diagnostics.eslint_d.with({
              condition = function(utils)
                return utils.root_has_file({ ".eslintrc", ".eslintrc.json", ".eslintrc.js" })
              end,
            }),

            -- ESLint for formatting (or you can use Prettier directly)
            null_ls.builtins.formatting.prettier.with({
              filetypes = { "javascript", "typescript", "css", "scss", "html", "json", "yaml", "markdown" },
            }),

            -- Black for formatting
            null_ls.builtins.formatting.black.with({
              extra_args = { "--line-length", "80" }, -- Optional: set line length for black
            }),
          },
        })
      end,
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

    lspconfig.eslint.setup {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Use null-ls for formatting
      end,
    }

    lspconfig.ts_ls.setup {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false -- Use null-ls for formatting
      end,
    }

    lspconfig.html.setup {
      cmd = { "vscode-html-language-server", "--stdio" },
      filetypes = { "html" },
    }

    lspconfig.cssls.setup({
      cmd = { "vscode-css-language-server", "--stdio" },
      filetypes = { "css", "scss", "less" },
      settings = {
        css = {
          validate = true,
        },
        scss = {
          validate = true,
        },
        less = {
          validate = true,
        },
      },
    })

    -- Format on :w
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        if client.supports_method('textDocument/formatting') then
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
