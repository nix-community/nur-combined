return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  build = ':TSUpdate',

  config = function()
    local config = require("nvim-treesitter.configs")
    config.setup({
      ensure_installed = { "markdown", "lua", "vim", "vimdoc" },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          scope_incremental = '<CR>',
          node_incremental = '<TAB>',
          node_decremental = '<S-TAB>',
        },
      },
      auto_install = true,
      disable = { "c" },
      highlight = { enable = true },
      indent = { enable = true },
    })

  end
}
