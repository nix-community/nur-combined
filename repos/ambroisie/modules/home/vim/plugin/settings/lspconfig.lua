local lsp = require("ambroisie.lsp")
local utils = require("ambroisie.utils")

-- Diagnostics
vim.diagnostic.config({
    -- Disable virtual test next to affected regions
    virtual_text = false,
    -- Also disable virtual diagnostics under the affected regions
    virtual_lines = false,
    -- Show diagnostics signs
    signs = true,
    -- Underline offending regions
    underline = true,
    -- Do not bother me in the middle of insertion
    update_in_insert = false,
    -- Show highest severity first
    severity_sort = true,
    jump = {
        -- Show float on diagnostic jumps
        float = true,
    },
})

-- Inform servers we are able to do completion, snippets, etc...
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Shared configuration
vim.lsp.config("*", {
    capabilities = capabilities,
    on_attach = lsp.on_attach,
})

local servers = {
    -- C/C++
    clangd = {},
    -- Haskell
    hls = {},
    -- Nix
    nil_ls = {},
    -- Python
    pyright = {},
    ruff = {},
    -- Rust
    rust_analyzer = {},
    -- Shell
    bashls = {
        filetypes = { "bash", "sh", "zsh" },
        settings = {
            bashIde = {
                shfmt = {
                    -- Simplify the code
                    simplifyCode = true,
                    -- Indent switch cases
                    caseIndent = true,
                },
            },
        },
    },
    -- Starlark
    starpls = {},
    -- Generic
    harper_ls = {},
    typos_lsp = {},
}

for server, config in pairs(servers) do
    if not vim.tbl_isempty(config) then
        vim.lsp.config(server, config)
    end
    vim.lsp.enable(server)
end
