return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'RRethy/vim-illuminate',
      'folke/neodev.nvim',
    },
    config = function()

      -- https://github.com/neovim/nvim-lspconfig
      -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
      local lsp = require("lspconfig")
      local illuminate = require("illuminate")

      -- local which_key = require("which-key")

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer.
      local on_attach = function(client, buffer)
        illuminate.on_attach(client)

        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(buffer, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

        -- See `:help vim.lsp.*` for documentation on any of the below functions
 --       which_key.register({
 --         g = {
 --           name = "Go",
 --           d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition" },
 --           D = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Go to declaration" },
 --           h = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Hover" },
 --           i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to implementation" },
 --           n = { "<cmd>lua require('illuminate').next_reference{wrap=true}<cr>", "Go to next occurrence" },
 --           p = { "<cmd>lua require('illuminate').next_reference{reverse=true,wrap=true}<cr>", "Go to previous occurrence" },
 --           r = { "<cmd>lua vim.lsp.buf.references()<cr>", "Go to references" },
 --           t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Go to type definition" },
 --           ["<C-k>"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "Signature help" }
 --         },
 --         ["["] = {
 --           d = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
 --         },
 --         ["]"] = {
 --           d = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous Diagnostic" },
 --         },
 --       }, { buffer = buffer, mode = "n", noremap = true, silent = true })

 --       which_key.register({
 --         w = {
 --           name = "Workspace",
 --           a = { "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", "Add workspace" },
 --           l = { "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", "List workspaces" },
 --           r = { "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", "Remove workspace" },
 --         },
 --         c = {
 --           name = "Code",
 --           a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Action" },
 --           f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
 --           r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
 --         }
 --       }, { buffer = buffer, mode = "n", prefix = "<leader>", noremap = true, silent = true })
     end

      --local capabilities = vim.lsp.protocol.make_client_capabilities()
      --capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure servers with common settings.
      local servers = {
        'rnix',
        'sqls',
        'gopls',
        'rust_analyzer',
      }

      for _, name in pairs(servers) do
        lsp[name].setup {
          on_attach = on_attach,
          capabilities = capabilities,
        }
      end

      -- TypeScript
      lsp.tsserver.setup {
        on_attach = on_attach,
        cmd = { "@typescriptLanguageServer@", "--stdio", "--tsserver-path", "@typescript@" },
        capabilities = capabilities,
      }

      -- ESLint
      lsp.eslint.setup {
        on_attach = on_attach,
        cmd = { "@eslintLanguageServer@", "--stdio" },
        capabilities = capabilities,
      }

      -- JSON
      lsp.jsonls.setup {
        on_attach = on_attach,
        cmd = { "@jsonLanguageServer@", "--stdio" },
        capabilities = capabilities,
      }

      -- HTML
      lsp.html.setup {
        on_attach = on_attach,
        cmd = { "@htmlLanguageServer@", "--stdio" },
        capabilities = capabilities,
      }

      -- CSS
      lsp.cssls.setup {
        on_attach = on_attach,
        cmd = { "@cssLanguageServer@", "--stdio" },
        capabilities = capabilities,
      }

      -- Docker
      lsp.dockerls.setup {
        on_attach = on_attach,
        cmd = { "@dockerLanguageServer@", "--stdio" },
        capabilities = capabilities,
      }

      lsp.lua_ls.setup({
        capabilites = capabilities,
      })

      -- Publish diagnostics from the language servers.
      vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
      })

      -- Configure diagnostic icons.
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Disable the preview window for omnifunc use.
      vim.cmd [[ set completeopt=menu ]]
    end,
  },
}
