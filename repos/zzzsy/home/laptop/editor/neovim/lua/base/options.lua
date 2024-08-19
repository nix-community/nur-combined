local options = {
  number = true,
  relativenumber = true,
  encoding = "utf-8",
  fileencoding = "utf-8",
  scrolloff = 5,
  sidescrolloff = 5,
  hlsearch = true,
  incsearch = true,
  mouse = "a",
  clipboard = "unnamedplus",
  tabstop = 2,
  softtabstop = 2,
  shiftwidth = 2,
  expandtab = true,
  ignorecase = true,
  smartcase = true,
  autoread = true,
  signcolumn = "yes",
  cursorline = true,
  wrap = false,
  termguicolors = true,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.scriptencoding = "utf-8"
vim.bo.autoread = true

--vim.g.mkdp_browser = 'chromium'

vim.cmd([[
function OpenMarkdownPreview (url)
  execute "silent ! firefox-beta --new-window --app=" . a:url
endfunction
]])

vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
