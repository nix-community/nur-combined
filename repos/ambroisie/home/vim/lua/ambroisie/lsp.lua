local M = {}

-- shared LSP configuration callback
-- @param client native client configuration
-- @param bufnr int? buffer number of the attched client
M.on_attach = function(client, bufnr)
    -- Diagnostics
    vim.diagnostic.config({
        -- Disable virtual test next to affected regions
        virtual_text = false,
        -- Show diagnostics signs
        signs = true,
        -- Underline offending regions
        underline = true,
        -- Do not bother me in the middle of insertion
        update_in_insert = false,
        -- Show highest severity first
        severity_sort = true,
    })

    vim.cmd([[
        augroup DiagnosticsHover
            autocmd! * <buffer>
            " Show diagnostics on "hover"
            autocmd CursorHold,CursorHoldI <buffer> lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})
        augroup END
    ]])

    -- Format on save
    if client.resolved_capabilities.document_formatting then
        vim.cmd([[
            augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup END
        ]])
    end

    -- Mappings
    local wk = require("which-key")

    local function list_workspace_folders()
        local utils = require("ambroisie.utils")
        utils.dump(vim.lsp.buf.list_workspace_folders())
    end

    local function show_line_diagnostics()
        vim.diagnostic.open_float(nil, { scope="line" })
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
            d = { show_line_diagnostics, "Show line diagnostics" },
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
