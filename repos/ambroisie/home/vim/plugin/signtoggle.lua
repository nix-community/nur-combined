local signtoggle = vim.api.nvim_create_augroup("signtoggle", { clear = true })

-- Only show sign column for the currently focused buffer
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "WinEnter" }, {
    pattern = "*",
    group = signtoggle,
    command = "setlocal signcolumn=yes",
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "WinLeave" }, {
    pattern = "*",
    group = signtoggle,
    command = "setlocal signcolumn=yes",
})

-- Never show the sign column in a terminal buffer
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    pattern = "*",
    group = signtoggle,
    command = "setlocal signcolumn=no",
})
