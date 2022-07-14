;; Imports
(local lspconfig (require :lspconfig))
(local coq (require :coq))
(local icons (require :nvim-web-devicons))
(local lsp_signature (require :lsp_signature))
(local lutils (require :lspconfig.util))
(local ls (require :luasnip))
(local types (require :luasnip.util.types))

;; Utils

(fn opt [key value]
  "Set a vim option"
  (tset vim.o key value))

(fn g [key value]
  "Set a vim global variable"
  (tset vim.g key value))

(fn cmd [...]
  "Run vim command"
  (vim.cmd ...))

(fn exec [...]
  "Run vimscript snippet"
  (vim.api.nvim_exec ...))

(fn nmap [key func ...]
  "Map key in normal mode to function"
  (vim.keymap.set :n key func ...))

; (lsp_signature.setup { :bind true })

(fn lsp [name options]
  (local opts (or options {}))
  (tset opts :on_attach (fn [client bufnr]
      (when (and options (. options :on_attach))
        ((. options :on_attach) client bufnr))
      ;; LSP mappings
      (local bufopts { :noremap true :silent true :buffer bufnr })
      (nmap "gD" vim.lsp.buf.declaration  bufopts)
      (nmap "gd" vim.lsp.buf.definition bufopts)
      (nmap "K" vim.lsp.buf.hover bufopts)
      (nmap "gi" vim.lsp.buf.implementation bufopts)
      (nmap "<C-k>" vim.lsp.buf.signature_help bufopts)
      (nmap "<space>wa" vim.lsp.buf.add_workspace_folder bufopts)
      (nmap "<space>wr" vim.lsp.buf.remove_workspace_folder bufopts)
      (nmap "<space>wl" (fn [] (print (vim.inspect (vim.lsp.buf.list_workspace_folders)))) bufopts)
      (nmap "<space>D" vim.lsp.buf.type_definition bufopts)
      (nmap "<space>rn" vim.lsp.buf.rename bufopts)
      (nmap "<space>ca" vim.lsp.buf.code_action bufopts)
      (nmap "gr" vim.lsp.buf.references bufopts)
      (nmap "<space>f" vim.lsp.buf.formatting bufopts)
      (print "LSP kicked in")
  ))
  (local coqed (coq.lsp_ensure_capabilities opts))
  (assert (. lspconfig name) (.. "The server " name " is not defined on lspconfig"))
  ((. (. lspconfig name) :setup) coqed)
)


;; LSP

(lsp :bashls)
(lsp :ccls { ;; C/C++
  :init_options {
    :cache 
      {:directory "/tmp/.ccls-cache"}
    :completion 
      {:detailedLabel false}
}})

(lsp :cmake)
(lsp :dockerls) ;; Dockerfile
(lsp :dotls) ;; GraphViz
(lsp :gopls) ;; Golang
(lsp :graphql) ;; GraphQL
(lsp :hls) ;; Haskell
(lsp :java_language_server { ;; Java
  :cmd [:java_language_server]
})
(lsp :pylsp) ;; Python
(lsp :rnix) ;; Nix
(lsp :rust_analyzer) ;; Rust
(lsp :terraformls) ;; Terraform
(lsp :texlab) ;; LaTeX
(lsp :tsserver) ;; TypeScript
(lsp :vimls) ;; VimL
(lsp :yamlls) ;; YAML
(lsp :zls) ;; Zig
(lsp :svelte) ;; Svelte

;; Luasnip
(ls.config.set_config {
  :history true
  :updateevents "TextChanged,TextChangedI"
  :enable_autosnippets true
  :ext_ops {
    types.choiceNode {
      :active {
        :virt_text [["<-" "Error"]]
      }
    }
  }
})

(when vim.keymap (do
  ; Needs nvim 0.7
  (vim.keymap.set [:i :s] "<c-k>" 
    (fn [] (when (ls.expand_or_jumpable) (ls.expand_or_jump)))
    {:silent true})

  ; Needs nvim 0.7
  (vim.keymap.set [:i :s] "<c-j>" 
    (fn [] (when (ls.jumpable -1) (ls.jump)))
    {:silent true})

  ; Needs nvim 0.7
  (vim.keymap.set [:i :s] "<c-l>" 
    (fn [] (when (ls.choice_active) (ls.change_choice 1)))
    {:silent true})
))

(let [
    ;; :help luasnip
    s ls.snippet
    sn ls.snippet_node
    isn ls.indent_snippet_node
    t ls.text_node
    i ls.insert_node
    f ls.function_node
    c ls.choice_node
    d ls.dynamic_node
    r ls.restore_node
  ]
  (do
    (ls.add_snippets :all [
      (s ":demo:" [ (i 1 "It works") ])
    ])
  ))

;; Telescope
(cmd "nmap <C-p> :Telescope<CR>")
(cmd "nmap <C-.> :Telescope lsp_code_actions<CR>")

(print "Config fennel carregada")
nil
