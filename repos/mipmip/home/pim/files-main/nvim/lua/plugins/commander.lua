-- Plugin Manager: lazy.nvim
return {
  "FeiyouG/commander.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
  },
  config = function()
    require("commander").setup({
      components = {
        "KEYS",
        "DESC",
        "CAT",
      },
      sort_by = {
        "CAT",
        "DESC",
        "KEYS",
        "CMD"
      },
      integration = {
        telescope = {
          enable = true,
        },
        lazy = {
          enable = true,
          set_plugin_name_as_cat = true
        }
      }
    })
  end,
}
