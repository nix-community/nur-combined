local success, err = pcall(require, 'adapter.fennel')
if not success then
    print("Failed to import the fennel stuff. LSP and the Lua stuff will not be available")
    print("Are you sure that your dotfiles is in ~/.dotfiles?")
else
    pcall(require, 'adapter.nvim')
end

-- local lspconfig = require'lspconfig'
-- local coq = require'coq'
-- local icons = require'nvim-web-devicons'
-- local lsp_signature = require 'lsp_signature'

-- lsp_signature.setup{
--     bind = true
-- }

-- local lspSettings = {
--     -- arduino_language_server = {},
--     bashls = {},
--     ccls = {
--         init_options = {
--             cache = {
--                 directory = "/tmp/.ccls-cache";
--             },
--             completion = {
--                 detailedLabel = false;
--             }
--         }
--     }, -- c/c++
--     cmake = {},
--     dockerls = {},
--     dotls = {}, -- dot/graphviz
--     -- emmet_ls = {},
--     -- fsautocomplete = {}, -- keep disabled for ionide-vim
--     gopls = {}, -- golang
--     graphql = {},
--     hls = {}, -- haskell
--     java_language_server = { -- java
--         cmd = { "java-language-server" };
--     },
--     rnix = {}, -- nix
--     rust_analyzer = {}, -- rust
--     terraformls = {}, -- terraform
--     texlab = {}, -- latex
--     tsserver = {}, -- typescript
--     vimls = {}, -- vimscript
--     yamlls = {}, -- yaml
--     zls = {}, -- zig
--     svelte = {} -- svelte
-- }

-- for server, _ in pairs(lspSettings) do
--     -- print("Setting up language server " .. server .. "...")
--     local coqed = coq.lsp_ensure_capabilities(lspSettings[server] or {})
--     if (lspconfig[server]) then
--         lspconfig[server].setup(coqed)
--     else
--         error("Language server definition " .. server .. " not found")
--     end
-- end

-- vim.cmd [[
--     nmap <C-p> :Telescope<CR>
--     nmap <C-.> :Telescope lsp_code_actions<CR>
-- ]]
