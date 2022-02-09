(local lspconfig (require :lspconfig))
(local coq (require :coq))
(local icons (require :nvim-web-devicons))

(local v (require :adapter.nvim.utils))

(require :adapter.nvim.lsp)
(require :adapter.nvim.luasnip)

(v.cmd "nmap <C-p> :Telescope<CR>")
(v.cmd "nmap <C-.> :Telescope lsp_code_actions<CR>")
nil
