lua << EOF
local ts_config = require("nvim-treesitter.configs")
ts_config.setup({
    highlight = {
        enable = true,
        -- Avoid duplicate highlighting
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true,
    },
    context_commentstring = {
        enable = true,
    },
    textobjects = {
        select = {
            enable = true,
            -- Jump to matching text objects
            lookahead = true,
            keymaps = {
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["ab"] = "@block.outer",
                ["ib"] = "@block.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ak"] = "@comment.outer",
                ["aS"] = "@statement.outer",
            },
        },
        move = {
            enable = true,
            -- Add to jump list
            set_jumps = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]S"] = "@statement.outer",
                ["]]"] = "@class.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[S"] = "@statement.outer",
                ["[["] = "@class.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
            },
        },
    },
})
EOF
