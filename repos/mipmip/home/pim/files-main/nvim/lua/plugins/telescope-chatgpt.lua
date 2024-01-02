return {
    {
        "HPRIOR/telescope-gpt",
        dependencies = { "nvim-telescope/telescope.nvim", "jackMort/ChatGPT.nvim" }
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.2",
        lazy = false,
        dependencies = { "nvim-lua/plenary.nvim" },
        version = false,
        opts = {
            extensions = {
                gpt = {
                    title = "Gpt Actions",
                    commands = {
                        "add_tests",
                        "chat",
                        "docstring",
                        "explain_code",
                        "fix_bugs",
                        "grammar_correction",
                        "interactive",
                        "optimize_code",
                        "summarize",
                        "translate"
                    },
                    theme = require("telescope.themes").get_dropdown{}
                }
            }
        },
        config = function(_, opts)
            require("telescope").setup(opts)
            require('telescope').load_extension('gpt')
        end,
    },
}
