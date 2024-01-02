return {
  "mipmip/nvim-mapper",
  dependencies = "nvim-telescope/telescope.nvim",
  enabled = false,
  config = function()
    require("nvim-mapper").setup({})
  end,
}
