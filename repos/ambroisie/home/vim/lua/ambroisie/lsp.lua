local M = {}

-- Simplified LSP formatting configuration
local lsp_format = require("lsp-format")

-- shared LSP configuration callback
-- @param client native client configuration
-- @param bufnr int? buffer number of the attched client
M.on_attach = function(client, bufnr)
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
    })

    -- Format on save
    lsp_format.on_attach(client, bufnr)

    -- Mappings
    local wk = require("which-key")

    local function list_workspace_folders()
        local utils = require("ambroisie.utils")
        utils.dump(vim.lsp.buf.list_workspace_folders())
    end

    local function cycle_diagnostics_display()
        -- Cycle from:
        -- * nothing displayed
        -- * single diagnostic at the end of the line (`virtual_text`)
        -- * full diagnostics using virtual text (`virtual_lines`)
        local text =  vim.diagnostic.config().virtual_text
        local lines = vim.diagnostic.config().virtual_lines

        -- Text -> Lines transition
        if text then
            text = false
            lines = true
        -- Lines -> Nothing transition
        elseif lines then
            text = false
            lines = false
        -- Nothing -> Text transition
        else
            text = true
            lines = false
        end

        vim.diagnostic.config({
            virtual_text = text,
            virtual_lines = lines,
        })
    end

    local function show_buffer_diagnostics()
        vim.diagnostic.open_float(nil, { scope="buffer" })
    end

    local keys = {
        K = { vim.lsp.buf.hover, "Show symbol information" },
        ["<C-k>"] = { vim.lsp.buf.signature_help, "Show signature information" },
        ["gd"] = { vim.lsp.buf.definition, "Go to definition" },
        ["gD"] = { vim.lsp.buf.declaration, "Go to declaration" },
        ["gi"] = { vim.lsp.buf.implementation, "Go to implementation" },
        ["gr"] = { vim.lsp.buf.references, "List all references" },

        ["<leader>c"] = {
            name = "Code",
            a = { vim.lsp.buf.code_action, "Code actions" },
            d = { cycle_diagnostics_display, "Cycle diagnostics display" },
            D = { show_buffer_diagnostics, "Show buffer diagnostics" },
            r = { vim.lsp.buf.rename, "Rename symbol" },
            s = { vim.lsp.buf.signature_help, "Show signature" },
            t = { vim.lsp.buf.type_definition, "Go to type definition" },
            w = {
                name = "Workspace",
                a = { vim.lsp.buf.add_workspace_folder, "Add folder to workspace" },
                l = { list_workspace_folders, "List folders in workspace" },
                r = { vim.lsp.buf.remove_workspace_folder, "Remove folder from workspace" },
            },
        },
    }

    wk.register(keys, { buffer = bufnr })
end


return M
