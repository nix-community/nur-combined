local map = require("other.utils").map
local rmap = vim.api.nvim_set_keymap

-- Remap <Space> as leader key
rmap("", ";", "<Nop>", { silent = true })
vim.g.mapleader = " "

map("i", "jk", "<Esc>")

map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<Esc>:w<CR>==gi")
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":wq<CR>")

map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")

map("i", "<C-u>", "<Esc>viwUea")
map("i", "<C-d>", "<Esc>b~lea")

map("n", "<C-n>", ":NvimTreeToggle<CR>")

map("n", "<leader>p", "m`o<Esc>p``", { desc = "paste below current line" })
map("n", "<leader>P", "m`O<Esc>p``", { desc = "paste above current line" })

map("n", "<C-Up>", ":resize -2<CR>")
map("n", "<C-Down>", ":resize +2<CR>")
map("n", "<C-Right>", ":vertical resize -2<CR>")
map("n", "<C-Left>", ":vertical resize +2<CR>")

-- Stay in indent mode
map("n", "<leader>,", "<ge")
map("n", "<leader>.", ">ge")

-- move line
map("n", "<leader>k", ":m .-2<CR>==")
map("n", "<leader>j", ":m .+1<CR>==")
map("i", "<C-k>", "<Esc>:m .-2<CR>==gi")
map("i", "<C-j>", "<Esc>:m .+1<CR>==gi")
map("v", "<C-k>", ":m '<-2<CR>gv=gv")
map("v", "<C-j>", ":m '>+1<CR>gv=gv")

map("n", "<C-a>", "gg<S-v>G")

map("n", "<leader>ss", ":vsplit<Return><C-w>w")
