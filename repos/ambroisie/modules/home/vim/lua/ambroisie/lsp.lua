local M = {}

-- Simplified LSP formatting configuration
local lsp_format = require("lsp-format")

--- shared LSP configuration callback
--- @param client native client configuration
--- @param bufnr int? buffer number of the attached client
M.on_attach = function(client, bufnr)
    -- Format on save
    lsp_format.on_attach(client, bufnr)

    -- Mappings
    local wk = require("which-key")

    local function list_workspace_folders()
        vim.print(vim.lsp.buf.list_workspace_folders())
    end

    local function cycle_diagnostics_display()
        -- Cycle from:
        -- * nothing displayed
        -- * single diagnostic at the end of the line (`virtual_text`)
        -- * full diagnostics using virtual text (`virtual_lines`)
        local text = vim.diagnostic.config().virtual_text
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
            jump = {
                -- Show float on jump if no diagnostic text is otherwise shown
                float = not (text or lines),
            },
        })
    end

    local function show_buffer_diagnostics()
        vim.diagnostic.open_float(nil, { scope = "buffer" })
    end

    local function toggle_inlay_hints()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end

    local keys = {
        buffer = bufnr,
        -- LSP navigation
        { "K", vim.lsp.buf.hover, desc = "Show symbol information" },
        { "<C-k>", vim.lsp.buf.signature_help, desc = "Show signature information" },
        { "gd", vim.lsp.buf.definition, desc = "Go to definition" },
        { "gD", vim.lsp.buf.declaration, desc = "Go to declaration" },
        { "gi", vim.lsp.buf.implementation, desc = "Go to implementation" },
        { "gr", vim.lsp.buf.references, desc = "List all references" },
        -- Code
        { "<leader>c", group = "Code" },
        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code actions" },
        { "<leader>cd", cycle_diagnostics_display, desc = "Cycle diagnostics display" },
        { "<leader>cD", show_buffer_diagnostics, desc = "Show buffer diagnostics" },
        { "<leader>ch", toggle_inlay_hints, desc = "Toggle inlay hints" },
        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename symbol" },
        { "<leader>cs", vim.lsp.buf.signature_help, desc = "Show signature" },
        { "<leader>ct", vim.lsp.buf.type_definition, desc = "Go to type definition" },
        -- Workspace
        { "<leader>cw", group = "Workspace" },
        { "<leader>cwa", vim.lsp.buf.add_workspace_folder, desc = "Add folder to workspace" },
        { "<leader>cwl", list_workspace_folders, desc = "List folders in workspace" },
        { "<leader>cwr", vim.lsp.buf.remove_workspace_folder, desc = "Remove folder from workspace" },
    }

    wk.add(keys)
end

--- list all active LSP clients for specific buffer, or all buffers
--- @param bufnr int? buffer number
--- @return table all active LSP client names
M.list_clients = function(bufnr)
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local names = {}

    for _, client in ipairs(clients) do
        table.insert(names, client.name)
    end

    return names
end

return M
