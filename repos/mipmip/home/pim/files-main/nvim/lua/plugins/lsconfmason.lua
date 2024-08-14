return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.tsserver.setup({
        capabilites = capabilities,
      })
      lspconfig.html.setup({
        capabilites = capabilities,
      })
      lspconfig.jsonls.setup({
        capabilites = capabilities,
      })

      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            diagnostics = {
              globals = {
                'vim',
                'pandoc',
                'require',
                'FORMAT'
              },
            },
          }
        },
        capabilites = capabilities,
      })
      lspconfig.rnix.setup({
        capabilites = capabilities,
      })
      lspconfig.marksman.setup({
        capabilites = capabilities,
      })

      lspconfig.terraformls.setup({
        capabilites = capabilities,
      })

      lspconfig.crystalline.setup({
        capabilites = capabilities,
      })

      lspconfig.bashls.setup({
        capabilites = capabilities,
      })

      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

      -- Configure diagnostic icons.
      local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

    end,
  },
}
