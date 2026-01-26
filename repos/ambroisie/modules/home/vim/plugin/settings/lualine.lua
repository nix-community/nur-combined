local lualine = require("lualine")
local oil = require("oil")
local lsp = require("ambroisie.lsp")

local function list_spell_languages()
    if not vim.opt.spell:get() then
        return ""
    end

    return table.concat(vim.opt.spelllang:get(), ", ")
end

local function list_lsp_clients()
    local client_names = lsp.list_clients(0)

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
            { "branch" },
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
        {
            sections = {
                lualine_a = {
                    { "mode" },
                },
                lualine_b = {
                    { "branch" },
                },
                lualine_c = {
                    function()
                        return vim.fn.fnamemodify(oil.get_current_dir(), ":~")
                    end,
                },
            },
            filetypes = { "oil" },
        },
    },
})
