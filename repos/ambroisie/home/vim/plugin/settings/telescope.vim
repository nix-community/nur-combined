lua << EOF
local telescope = require("telescope")

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<C-h>"] = "which_key",
                -- I want the normal readline mappings rather than scrolling
                ["<C-u>"] = false,
            }
        }
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})

telescope.load_extension("fzf")
telescope.load_extension("lsp_handlers")
EOF
