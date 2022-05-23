lua << EOF
local wk = require("which-key")

local keys = {
    ["<leader>"] = { "<cmd>nohls<CR>", "Clear search highlight" },
}

wk.register(keys, { prefix = "<leader>" })
EOF
