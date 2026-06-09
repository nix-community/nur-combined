local lsp_format = require("lsp-format")

lsp_format.setup({})

local format = vim.api.nvim_create_augroup("ambroisie.format", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
    group = format,
    callback = function(args)
        local buf, data = args.buf, args.data
        local client = assert(vim.lsp.get_client_by_id(data.client_id))
        require("lsp-format").on_attach(client, buf)
    end,
})
