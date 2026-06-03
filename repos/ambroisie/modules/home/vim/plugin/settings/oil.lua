local oil = require("oil")
local wk = require("which-key")

local detail = false

oil.setup({
    view_options = {
        -- Show files and directories that start with "." by default
        show_hidden = true,
        -- But never '..'
        is_always_hidden = function(name, bufnr)
            return name == ".."
        end,
    },
    keymaps = {
        ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
                detail = not detail
                if detail then
                    oil.set_columns({ "icon", "permissions", "size", "mtime" })
                else
                    oil.set_columns({ "icon" })
                end
            end,
        },
        -- Use better `cd` mappings
        ["`"] = false,
        ["~"] = false,
        ["g`"] = { "actions.cd", mode = "n" },
        ["g~"] = { "actions.cd", opts = { scope = "win" }, mode = "n" },
    },
})

local keys = {
    { "-", oil.open, desc = "Open parent directory" },
}

wk.add(keys)
