lua << EOF
local lualine = require("lualine")
local utils = require("ambroisie.utils")

local function list_spell_languages()
    if not vim.opt.spell:get() then
        return ""
    end

    return table.concat(vim.opt.spelllang:get(), ", ")
end

local function list_lsp_clients()
    local client_names = utils.list_lsp_clients()

    if #client_names == 0 then
        return ""
    end

    return "[ " .. table.concat(client_names, " ") .. " ]"
end

lualine.setup({
    options = {
        icons_enabled = false,
        section_separators = "",
        component_separators = "|",
    },
    sections = {
        lualine_a = {
            { "mode" },
        },
        lualine_b = {
            { "FugitiveHead" },
            { "filename", symbols = { readonly = "🔒" } },
        },
        lualine_c = {
            { list_spell_languages },
            { "lsp_progress" },
        },
        lualine_x = {
            { list_lsp_clients },
            {
                "diagnostics",
                -- Only use the diagnostics API
                sources = { "nvim_diagnostic" },
            },
        },
        lualine_y = {
            { "fileformat" },
            { "encoding" },
            { "filetype" },
        },
        lualine_z = {
            "location",
        },
    },
    extensions = {
        "fugitive",
        "quickfix",
    },
})
EOF
