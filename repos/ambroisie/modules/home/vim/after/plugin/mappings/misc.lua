local wk = require("which-key")

local keys = {
    { "<leader><leader>", "<cmd>nohls<CR>", desc = "Clear search highlight" },
}

wk.add(keys)
