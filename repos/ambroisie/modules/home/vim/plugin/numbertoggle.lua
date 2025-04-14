-- Show lines numbers
vim.opt.number = true

local numbertoggle = vim.api.nvim_create_augroup("numbertoggle", { clear = true })

-- Toggle numbers between relative and absolute when changing buffers
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
    pattern = "*",
    group = numbertoggle,
    callback = function()
        if vim.opt.number:get() then
            vim.opt.relativenumber = true
        end
    end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
    pattern = "*",
    group = numbertoggle,
    callback = function()
        if vim.opt.number:get() then
            vim.opt.relativenumber = false
        end
    end,
})
