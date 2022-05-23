lua << EOF
local gitsigns = require('gitsigns')
local wk = require("which-key")

gitsigns.setup({
    -- I dislike the full-green sign column when this happens
    attach_to_untracked = false,

    current_line_blame_opts = {
        -- Show the blame quickly
        delay = 100,
    },
})

local keys = {
    -- Navigation
    ["[c"] = { "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", "Previous hunk/diff", expr = true },
    ["]c"] = { "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", "Next hunk/diff", expr = true },


    -- Commands
    ["<leader>g"] = {
        name = "Git",
        -- Actions
        b = { gitsigns.toggle_current_line_blame, "Toggle blame virtual text" },
        d = { gitsigns.diffthis, "Diff buffer" },
        D = { function() gitsigns.diffthis("~") end, "Diff buffer against last commit" },
        g = { "<cmd>Git<CR>", "Git status" },
        h = { gitsigns.toggle_deleted, "Show deleted hunks" },
        L = { "<cmd>:sp<CR><C-w>T:Gllog --follow -- %:p<CR>", "Current buffer log" },
        m = { "<Plug>(git-messenger)", "Current line blame" },
        p = { gitsigns.preview_hunk, "Preview hunk" },
        r = { gitsigns.reset_hunk, "Restore hunk" },
        R = { gitsigns.reset_buffer, "Restore buffer" },
        s = { gitsigns.stage_hunk, "Stage hunk" },
        S = { gitsigns.stage_buffer, "Stage buffer" },
        u = { gitsigns.undo_stage_hunk, "Undo stage hunk" },
        ["["] = { gitsigns.prev_hunk, "Previous hunk" },
        ["]"] = { gitsigns.next_hunk, "Next hunk" },
    },
}

local objects = {
    ["ih"] = { gitsigns.select_hunk, "Git hunk" },
}

local visual = {
    ["ih"] = { gitsigns.select_hunk, "Git hunk" },

    -- Only the actual command can make use of the visual selection...
    ["<leader>g"] = {
        name = "Git",
        p = { ":Gitsigns preview_hunk<CR>", "Preview selection" },
        r = { ":Gitsigns reset_hunk<CR>", "Restore selection" },
        s = { ":Gitsigns stage_hunk<CR>", "Stage selection" },
        u = { ":Gitsigns undo_stage_hunk<CR>", "Undo stage selection" },
    },
}

wk.register(keys, { buffer = bufnr })
wk.register(objects, { buffer = bufnr, mode = "o" })
wk.register(visual, { buffer = bufnr, mode = "x" })
EOF
