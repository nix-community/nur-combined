local wk = require("which-key")
wk.setup({
    icons = {
        -- I don't like icons
        mappings = false,
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        ellipsis = "…",
        keys = {
            Up = " ",
            Down = " ",
            Left = " ",
            Right = " ",
            C = "<C>",
            M = "<M>",
            D = "<D>",
            S = "<S>",
            CR = "<CR>",
            Esc = "<Esc> ",
            NL = "<NL>",
            BS = "<BS>",
            Space = "<space>",
            Tab = "<Tab> ",
        },
    },
})
