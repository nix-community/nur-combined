-- Use GLSL filetype for common shader file extensions
vim.filetype.add({
    extension = {
        frag = "glsl",
        vert = "glsl",
    },
})
