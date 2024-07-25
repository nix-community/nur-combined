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
    textobjects = {
        select = {
            enable = true,
            -- Jump to matching text objects
            lookahead = true,
            keymaps = {
                ["aa"] = { query = "@parameter.outer", desc = "a parameter" },
                ["ia"] = { query = "@parameter.inner", desc = "inner parameter" },
                ["ab"] = { query = "@block.outer", desc = "a block" },
                ["ib"] = { query = "@block.inner", desc = "inner block" },
                ["ac"] = { query = "@class.outer", desc = "a class" },
                ["ic"] = { query = "@class.inner", desc = "inner class" },
                ["af"] = { query = "@function.outer", desc = "a function" },
                ["if"] = { query = "@function.inner", desc = "inner function" },
                ["ak"] = { query = "@comment.outer", desc = "a comment" },
                ["aS"] = { query = "@statement.outer", desc = "a statement" },
            },
        },
        move = {
            enable = true,
            -- Add to jump list
            set_jumps = true,
            goto_next_start = {
                ["]m"] = { query = "@function.outer", desc = "Next method start" },
                ["]S"] = { query = "@statement.outer", desc = "Next statement start" },
                ["]]"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_next_end = {
                ["]M"] = { query = "@function.outer", desc = "Next method end" },
                ["]["] = { query = "@class.outer", desc = "Next class end" },
            },
            goto_previous_start = {
                ["[m"] = { query = "@function.outer", desc = "Previous method start" },
                ["[S"] = { query = "@statement.outer", desc = "Previous statement start" },
                ["[["] = { query = "@class.outer", desc = "Previous class start" },
            },
            goto_previous_end = {
                ["[M"] = { query = "@function.outer", desc = "Previous method end" },
                ["[]"] = { query = "@class.outer", desc = "Previous class end" },
            },
        },
    },
})
