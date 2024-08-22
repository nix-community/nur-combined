return {
  {
    "tadmccorkle/markdown.nvim",
    enabled = false,
    ft = "markdown", -- or 'event = "VeryLazy"'
    opts = {
      -- configuration here or empty for defaults
    },
  },
  {
    "roodolv/markdown-toggle.nvim",
    config = function()
      require("markdown-toggle").setup()

      vim.api.nvim_create_autocmd("FileType", {
        desc = "markdown-toggle.nvim keymaps",
        pattern = { "markdown", "markdown.mdx" },
        callback = function(args)
          local opts = { silent = true, noremap = true, buffer = args.buf }
          local toggle = require("markdown-toggle")

          opts.expr = true -- required for dot-repeat in Normal mode
--          vim.keymap.set("n", "<C-q>", toggle.quote_dot, opts)
--          vim.keymap.set("n", "<C-l>", toggle.list_dot, opts)
--          vim.keymap.set("n", "<C-n>", toggle.olist_dot, opts)
          vim.keymap.set("n", "-", toggle.checkbox_dot, opts)
--          vim.keymap.set("n", "<C-h>", toggle.heading_dot, opts)

          opts.expr = false -- required for Visual mode
--          vim.keymap.set("x", "<C-q>", toggle.quote, opts)
--          vim.keymap.set("x", "<C-l>", toggle.list, opts)
--          vim.keymap.set("x", "<C-n>", toggle.olist, opts)
          vim.keymap.set("x", "-", toggle.checkbox, opts)
--          vim.keymap.set("x", "<C-h>", toggle.heading, opts)

          -- Keymap configurations will be added here for each feature

        end,
      })
    end,
  },
}
