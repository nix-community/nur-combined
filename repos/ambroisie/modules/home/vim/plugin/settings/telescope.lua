local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")
local wk = require("which-key")

telescope.setup({
    defaults = {
        mappings = {
            i = {
                ["<C-h>"] = "which_key",
                -- I want the normal readline mappings rather than scrolling
                ["<C-u>"] = false,
            },
        },
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

local keys = {
    { "<leader>f", group = "Fuzzy finder" },
    { "<leader>fb", telescope_builtin.buffers, desc = "Open buffers" },
    { "<leader>ff", telescope_builtin.git_files, desc = "Git tracked files" },
    { "<leader>fF", telescope_builtin.find_files, desc = "Files" },
    { "<leader>fg", telescope_builtin.live_grep, desc = "Grep string" },
    { "<leader>fG", telescope_builtin.grep_string, desc = "Grep string under cursor" },
}

wk.add(keys)
