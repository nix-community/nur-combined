return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',

  -- telescope mappings are in keymaps.lua
  config = function()
    require("telescope").load_extension("mapper")
    require("telescope").load_extension("http")
    require("telescope").load_extension("emoji")
    require("telescope").load_extension("terraform_doc")
  end,

  dependencies = {
    'nvim-lua/plenary.nvim',
    'barrett-ruth/telescope-http.nvim',
    'ANGkeith/telescope-terraform-doc.nvim',
    'xiyaowong/telescope-emoji.nvim',
    'FeiyouG/commander.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
}

