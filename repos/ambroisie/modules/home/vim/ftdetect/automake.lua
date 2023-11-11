-- Use Automake filetype for `local.am` files, explicit `set` to force override
vim.filetype.add({
    filename = {
        ["local.am"] = "automake",
    },
})
