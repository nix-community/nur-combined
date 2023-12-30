return {
  "mipmip/nvim-mapper",
  dependencies = "nvim-telescope/telescope.nvim",
  config = function()
    require("nvim-mapper").setup({})
  end,
}
