local signtoggle = vim.api.nvim_create_augroup("signtoggle", { clear = true })

-- Only show sign column for the currently focused buffer, if it has a number column
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "WinEnter" }, {
    pattern = "*",
    group = signtoggle,
    callback = function()
        if vim.opt.number:get() then
            vim.opt.signcolumn = "yes"
        end
    end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "WinLeave" }, {
    pattern = "*",
    group = signtoggle,
    callback = function()
        if vim.opt.number:get() then
            vim.opt.signcolumn = "no"
        end
    end,
})
