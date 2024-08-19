-- local theme = require("other.utils").get_colorscheme()

return {
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("everforest").setup({
        background = "soft",
      })
      vim.cmd("colorscheme everforest")
    end,
  }
}
