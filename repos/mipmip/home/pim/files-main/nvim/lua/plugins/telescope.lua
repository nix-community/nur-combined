return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',

  config = function()
    local builtin = require('telescope.builtin')
    require("telescope").load_extension("mapper")
    -- mappings are in keymaps.lua

  end,

  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
}

