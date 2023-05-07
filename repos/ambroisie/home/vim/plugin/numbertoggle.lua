-- Show lines numbers
vim.opt.number = true

local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })

-- Toggle numbers between relative and absolute when changing buffers
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    pattern = "*",
    group = numbertoggle,
    command = "if &nu | setlocal rnu | endif",
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    pattern = "*",
    group = numbertoggle,
    command = "if &nu | setlocal nornu | endif",
})

-- Never show the sign column in a terminal buffer
vim.api.nvim_create_autocmd({ "TermOpen" }, {
    pattern = "*",
    group = numbertoggle,
    command = "setlocal nonu nornu",
})
