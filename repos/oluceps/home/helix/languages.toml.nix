{ pkgs, ... }:
''
  [[language]]
  file-types = ["typ"]
  injection-regex = "typ"
  language-servers = ["tinymist"]
  name = "typst"
  roots = []
  scope = "source.typst"

  [language.soft-wrap]
  enable = true

  [[language]]
  file-types = ["tex"]
  language-servers = ["texlab"]
  name = "latex"
  # formatter = { command = 'prettier', args = ["--plugin", "${pkgs.prettier-plugin-latex}/lib/node_modules/prettier-plugin-latex/dist/prettier-plugin-latex.js","--parser", "latex-parser"] }
  [language.soft-wrap]
  enable = true

  [[language]]
  file-types = ["md"]
  language-servers = ["markdown-oxide"]
  name = "markdown"
  [language.soft-wrap]
  enable = true


  [[language]]
  language-servers = ["nixd", "nil"]
  name = "nix"

  [language.formatter]
  command = "nixfmt"

  [[language]]
  name = "jsonc"
  file-types = ["json","jsonc"]

  [language.formatter]
  args = ["--parser","json"]
  command = "prettier"

  [language-server]
  [language-server.awk-language-server]
  command = "awk-language-server"

  [language-server.biome]
  command = "biome"
  args = ["lsp-proxy"]

  [language-server.markdown-oxide]
  command = "markdown-oxide"

  [language-server.bash-language-server]
  args = ["start"]
  command = "bash-language-server"

  [language-server.clangd]
  command = "clangd"

  [language-server.cmake-language-server]
  command = "cmake-language-server"

  [language-server.docker-langserver]
  args = ["--stdio"]
  command = "docker-langserver"

  [language-server.haskell-language-server]
  args = ["--lsp"]
  command = "haskell-language-server-wrapper"

  [language-server.idris2-lsp]
  command = "idris2-lsp"

  [language-server.jsonnet-language-server]
  args = ["-t", "--lint"]
  command = "jsonnet-language-server"

  [language-server.julia]
  args = ["--startup-file=no", "--history-file=no", "--quiet", "-e", "using LanguageServer; runserver()"]
  command = "julia"
  timeout = 60

  [language-server.kotlin-language-server]
  command = "kotlin-language-server"

  [language-server.lean]
  args = ["--server"]
  command = "lean"

  [language-server.markdoc-ls]
  args = ["--stdio"]
  command = "markdoc-ls"

  [language-server.marksman]
  args = ["server"]
  command = "marksman"

  [language-server.nil]
  command = "nil"

  [language-server.nixd]
  command = "nixd"

  [language-server.ocamllsp]
  command = "ocamllsp"

  [language-server.pylsp]
  command = "pylsp"

  [language-server.taplo]
  args = ["lsp", "stdio"]
  command = "taplo"

  [language-server.texlab]
  command = "texlab"

  [language-server.typst-lsp]
  command = "tinymist"

  [language-server.vscode-css-language-server]
  args = ["--stdio"]
  command = "css-languageserver"

  [language-server.vscode-css-language-server.config]
  provideFormatter = true

  [language-server.vscode-html-language-server]
  args = ["--stdio"]
  command = "html-languageserver"

  [language-server.vscode-html-language-server.config]
  provideFormatter = true

  [language-server.vscode-json-language-server]
  args = ["--stdio"]
  command = "vscode-json-languageserver"

  [language-server.vscode-json-language-server.config]
  provideFormatter = true

  [language-server.vuels]
  command = "vls"

  [language-server.yaml-language-server]
  args = ["--stdio"]
  command = "yaml-language-server"

  [language-server.zls]
  command = "zls"
''
