;; Opções básicas
(vim.api.nvim_create_user_command :Dosify (fn [opts]
  (tset vim.b :ff :dos)) {})

(vim.cmd "map gy \"+y")
(vim.cmd "map gp \"+p")
(vim.cmd "map gd \"+d")
(vim.cmd "noremap <C-n> :nohl<CR>")

(tset vim.o :encoding :utf-8) ;; Sempre usar utf-8 ao salvar
(tset vim.o :number true) ;; Numeração de linhas
(tset vim.o :showmatch true) ;; Highlight de parenteses e chaves
(tset vim.o :syntax true) ;; Syntax highlight
(vim.cmd "filetype plugin on") ;; Coisa de plugin
(tset vim.o :path (.. vim.o.path ",**")) ;; Busca recursiva

;; Indentação
(tset vim.o :autoindent true) ;; Mantém níveis de indentação
(tset vim.o :tabstop 4) ;; Tab -> 4 espaços
(tset vim.o :softtabstop 4) ;; Padding que mostra
(tset vim.o :shiftwidth 4) ;; > ou < puxa quanto
(tset vim.o :shiftround true) ;; Arredonda identação
(tset vim.o :expandtab true) ;; Tab vira espaços
(tset vim.o :list true) ;; Mostra indentação

;; Especificidade
(tset vim.o :backup false) ;; Mostra indentação
(tset vim.o :compatible false) ;; Compatibilidade com vi
(tset vim.o :mouse :a) ;; Aceitar comando de mouse
(tset vim.o :completeopt "menuone,noinsert,noselect,preview")
(tset vim.o :previewheight 3) ;; Altura máxima da janela de preview

(tset vim.o :omnifunc :v:lua.vim.lsp.omnifunc)

(tset vim.g :mapleader ",") ;; Mapeia leader

;; Wildmenu: autocomplete para o modo de comando
(tset vim.o :wildmenu true)
(tset vim.o :wildmode "list:longest,full")

(tset vim.o :wildignore "*.pyc,*.o,*.class")

;; Imports
(local coq (require :coq))

;; AutoPairs
(tset vim.g :AutoPairsMultilineClose false)

;; Echodoc
(tset vim.g :echodoc#enable_at_startup true)
(tset vim.o :showmode false)
(tset vim.g :echodoc#type :virtual)

;; Markdown
(vim.cmd "au! BufRead,BufNewFile *.markdown set filetype=mkd")
(vim.cmd "au! BufRead,BufNewFile *.md       set filetype=mkd")

(tset vim.g :vim_markdown_folding_disabled true)
(tset vim.g :vim_markdown_fenced_languages [
  :bash=sh
  :c++=cpp
  :ini=dosini
  :viml=vim
])

(tset vim.g :vim_markdown_math true)
(tset vim.g :vim_markdown_frontmatter true)
(tset vim.g :vim_markdown_strikethrough true)
(tset vim.g :vim_markdown_new_list_item_indent true)
(tset vim.g :vim_markdown_no_extensions_in_markdown true)

;; Disable concealing because it sucks
(vim.cmd "autocmd VimEnter * set conceallevel=0")

;; F-Sharp remapping
;; TODO: Is this necessary?
(vim.cmd "autocmd BufNewFile,BufRead *.fs,*.fsx,*.fsi set filetype=fsharp")

;; Fennel
(tset vim.g :fennel_nvim_auto_init false)

;; lsp_signature
(local lsp_signature (require :lsp_signature))
(lsp_signature.setup { :bind true })

;; nvim-web-devicons
((. (require :nvim-web-devicons) :setup) {
  :default true
})

;; Trouble
(vim.diagnostic.config {:virtual_text false})
(. (require :trouble) :setup)

;; LSP
(let [
  lspconfig (require :lspconfig)

  lsp (fn [name options]
    (local opts (or options {}))
    (tset opts :on_attach (fn [client bufnr]
        (when (and options (. options :on_attach))
          ((. options :on_attach) client bufnr))
        ;; LSP mappings
        (local bufopts { :noremap true :silent true :buffer bufnr })
        (vim.keymap.set :n :gD vim.lsp.buf.declaration  bufopts)
        (vim.keymap.set :n :gd vim.lsp.buf.definition bufopts)
        (vim.keymap.set :n :K vim.lsp.buf.hover bufopts)
        (vim.keymap.set :n :gi vim.lsp.buf.implementation bufopts)
        (vim.keymap.set :n :<C-k> vim.lsp.buf.signature_help bufopts)
        (vim.keymap.set :n :<space>wa vim.lsp.buf.add_workspace_folder bufopts)
        (vim.keymap.set :<space>wr vim.lsp.buf.remove_workspace_folder bufopts)
        (vim.keymap.set :<space>wl (fn [] (print (vim.inspect (vim.lsp.buf.list_workspace_folders)))) bufopts)
        (vim.keymap.set :<space>D vim.lsp.buf.type_definition bufopts)
        (vim.keymap.set :<space>rn vim.lsp.buf.rename bufopts)
        (vim.keymap.set :<space>ca vim.lsp.buf.code_action bufopts)
        (vim.keymap.set :gr vim.lsp.buf.references bufopts)
        (vim.keymap.set :<space>f vim.lsp.buf.formatting bufopts)
        (print "LSP kicked in")
    ))
    (local coqed (coq.lsp_ensure_capabilities opts))
    (assert (. lspconfig name) (.. "The server " name " is not defined on lspconfig"))
    ((. (. lspconfig name) :setup) coqed)
  )

] (do

  ;; LSP
  (lsp :ansiblels) ;; Ansible
  (lsp :bashls) ;; Bash
  (lsp :ccls { ;; C/C++
    :init_options {
      :cache 
        {:directory "/tmp/.ccls-cache"}
      :completion 
        {:detailedLabel false}
  }})

  (lsp :cmake) ;; CMake
  (lsp :dockerls) ;; Dockerfile
  (lsp :dotls) ;; GraphViz
  (lsp :elixirls { ;; Elixir
      :cmd [:elixir-ls]
  })
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

))

;; Telescope
(vim.keymap.set [:n] :<C-p> (fn [] (vim.cmd.Telescope)))
(vim.keymap.set [:n] :<C-.> (fn [] (vim.cmd.Telescope :lsp_code_actions)))

;; COQ
(tset vim.g :coq_settings {
  :xdg true
  :keymap.recommended true
  :auto_start :shut-up
})
(vim.cmd.COQnow :--shut-up)

(vim.keymap.set [:i :s] :<c-k>
  (fn [] (when (ls.expand_or_jumpable) (ls.expand_or_jump)))
  {:silent true})

(vim.keymap.set [:i :s] :<c-j>
  (fn [] (when (ls.jumpable -1) (ls.jump)))
  {:silent true})

(vim.keymap.set [:i :s] :<c-l>
  (fn [] (when (ls.choice_active) (ls.change_choice 1)))
  {:silent true})

;; Luasnip
(let [
    ;; :help luasnip
    ls (require :luasnip)
    types (require :luasnip.util.types)

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

))

; Theming
(tset vim.g :nixcfg_is_dark true)

(let
  [
    default-white-theme :paper
    default-dark-theme :embark
    nix-colors-theme vim.g.nix_colors_theme
    custom-theme (if (= nix-colors-theme "") nil nix-colors-theme)
    chosen-dark-theme (or custom-theme default-dark-theme)
  ]
  (do
    (vim.cmd.colorscheme chosen-dark-theme)
    (vim.api.nvim_create_user_command :ToggleTheme (fn [opts]
      (let [
            is-dark (not vim.g.nixcfg_is_dark) ;; inverter pq é dark por padrão
            chosen-theme (if is-dark chosen-dark-theme default-white-theme)
        ] (do
            (tset vim.g :nixcfg_is_dark is-dark)
            (vim.cmd.colorscheme chosen-theme)
            (print "theme: " chosen-theme)
          ))
      ) {})))

; (print "Config fennel carregada")

nil
