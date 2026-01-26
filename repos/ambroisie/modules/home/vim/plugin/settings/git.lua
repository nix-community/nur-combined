local gitsigns = require("gitsigns")
local utils = require("ambroisie.utils")
local wk = require("which-key")

--- Transform `f` into a function which acts on the current visual selection
local function make_visual(f)
    return function()
        local first = vim.fn.line("v")
        local last = vim.fn.line(".")
        f({ first, last })
    end
end

local function nav_hunk(dir)
    if vim.wo.diff then
        local map = {
            prev = "[c",
            next = "]c",
        }
        vim.cmd.normal({ map[dir], bang = true })
    else
        gitsigns.nav_hunk(dir)
    end
end

gitsigns.setup({
    current_line_blame_opts = {
        -- Show the blame quickly
        delay = 100,
    },
    -- Work-around for https://github.com/lewis6991/gitsigns.nvim/issues/929
    signs_staged_enable = false,
})

local keys = {
    -- Navigation
    { "[c", utils.partial(nav_hunk, "prev"), desc = "Previous hunk/diff" },
    { "]c", utils.partial(nav_hunk, "next"), desc = "Next hunk/diff" },
    -- Commands
    { "<leader>g", group = "Git" },
    { "<leader>gb", gitsigns.toggle_current_line_blame, desc = "Toggle blame virtual text" },
    { "<leader>gd", gitsigns.diffthis, desc = "Diff buffer" },
    { "<leader>gD", utils.partial(gitsigns.diffthis, "~"), desc = "Diff buffer against last commit" },
    { "<leader>gg", "<cmd>Git<CR>", desc = "Git status" },
    { "<leader>gh", gitsigns.toggle_deleted, desc = "Show deleted hunks" },
    { "<leader>gL", "<cmd>:sp<CR><C-w>T:Gllog --follow -- %:p<CR>", desc = "Current buffer log" },
    { "<leader>gm", "<Plug>(git-messenger)", desc = "Current line blame" },
    { "<leader>gp", gitsigns.preview_hunk, desc = "Preview hunk" },
    { "<leader>gr", gitsigns.reset_hunk, desc = "Restore hunk" },
    { "<leader>gR", gitsigns.reset_buffer, desc = "Restore buffer" },
    { "<leader>gs", gitsigns.stage_hunk, desc = "Stage hunk" },
    { "<leader>gS", gitsigns.stage_buffer, desc = "Stage buffer" },
    { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo stage hunk" },
    { "<leader>g[", utils.partial(gitsigns.nav_hunk, "prev"), desc = "Previous hunk" },
    { "<leader>g]", utils.partial(gitsigns.nav_hunk, "next"), desc = "Next hunk" },
}

local objects = {
    mode = "o",
    { "ih", gitsigns.select_hunk, desc = "git hunk" },
}
-- Visual
local visual = {
    mode = { "x" },
    { "ih", gitsigns.select_hunk, desc = "git hunk" },
    { "<leader>g", group = "Git" },
    { "<leader>gp", gitsigns.preview_hunk, desc = "Preview selection" },
    { "<leader>gr", make_visual(gitsigns.reset_hunk), desc = "Restore selection" },
    { "<leader>gs", make_visual(gitsigns.stage_hunk), desc = "Stage selection" },
    { "<leader>gu", gitsigns.undo_stage_hunk, desc = "Undo stage selection" },
}

wk.add(keys)
wk.add(objects)
wk.add(visual)
