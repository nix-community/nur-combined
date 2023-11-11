-- Use bash filetype for `.envrc` files
vim.filetype.add({
    filename = {
        [".envrc"] = "bash",
    },
})
