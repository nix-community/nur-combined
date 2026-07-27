{ lib }:
{
  # keep-sorted start block=yes
  airwindows-consolidated = [ "airwin2rack" ];
  cantata = [ "cantata" ];
  distrho-ports = [ "distrho-ports" ];
  emacsPackages =
    builtins.mapAttrs
      (_: name: [
        "emacsPackages"
        name
      ])
      {
        eglot-booster = "eglot-booster";
        eglot-inactive-regions = "eglot-inactive-regions";
        indent-bars = "indent-bars";
        on = "on";
        once = "once";
        smartparens = "smartparens";
      };
  geonkick = [ "geonkick" ];
  giada = [ "giada" ];
  haskellPackages =
    builtins.mapAttrs
      (_: name: [
        "haskellPackages"
        name
      ])
      {
        kmonad = "kmonad";
        taffybar = "taffybar";
        xmonad-entryhelper = "xmonad-entryhelper";
      };
  luakit = [ "luakit" ];
  mesonlsp-bin = [ "mesonlsp" ];
  molot-lite = [ "molot-lite" ];
  nimlangserver = [ "nimlangserver" ];
  nodePackages = {
    emmet-ls = [ "emmet-ls" ];
    emmet-language-server = [ "emmet-language-server" ];
    tailwindcss-language-server = [ "tailwindcss-language-server" ];
  };
  nu-lint = [ "nu-lint" ];
  nugget-doom = [ "nugget-doom" ];
  ob-xf = [ "ob-xf" ];
  onagre = [ "onagre" ];
  powertab = [ "powertab-editor" ];
  ripplerx = [ "ripplerx" ];
  rnnoise-plugin = [ "rnnoise-plugin" ];
  satty = [ "satty" ];
  sg-323 = [ "sg-323" ];
  six-sines = [ "six-sines" ];
  sox-ng = [ "sox_ng" ];
  symbols-nerd-font = [
    "nerd-fonts"
    "symbols-only"
  ];
  tack = [ "tack" ];
  treeSitterGrammars.hypr = [
    "tree-sitter-grammars"
    "tree-sitter-hyprland"
  ];
  uhhyou = [ "uhhyou-plugins" ];
  uzdoom = [ "uzdoom" ];
  vgmtrans = [ "vgmtrans" ];
  vimPlugins =
    lib.genAttrs
      [
        "FTerm-nvim"
        "SchemaStore-nvim"
        "aniseed"
        "astrocore"
        "barbar-nvim"
        "blink-compat"
        "bufferline-nvim"
        "cheatsheet-nvim"
        "cinnamon-nvim"
        "clangd_extensions-nvim"
        "cmake-tools-nvim"
        "cmp-cmdline"
        "cmp-latex-symbols"
        "cmp-nvim-lsp"
        "cmp-nvim-lsp-document-symbol"
        "cmp-nvim-lua"
        "cmp-path"
        "cmp-under-comparator"
        "cmp_luasnip"
        "colortils-nvim"
        "conform-nvim"
        "coq_nvim"
        "crates-nvim"
        "cybu-nvim"
        "dashboard-nvim"
        "dhall-vim"
        "diaglist-nvim"
        "direnv-vim"
        "dressing-nvim"
        "edgy-nvim"
        "editorconfig-nvim"
        "faust-nvim"
        "fidget-nvim"
        "flutter-tools-nvim"
        "formatter-nvim"
        "friendly-snippets"
        "fzf-lua"
        "galaxyline-nvim"
        "gitsigns-nvim"
        "glance-nvim"
        "go-nvim"
        "guess-indent-nvim"
        "haskell-tools-nvim"
        "heirline-nvim"
        "hlargs-nvim"
        "hover-nvim"
        "impatient-nvim"
        "inc-rename-nvim"
        "incline-nvim"
        "indent-blankline-nvim"
        "lazy-nvim"
        "legendary-nvim"
        "lsp_extensions-nvim"
        "lsp_lines-nvim"
        "lsp_signature-nvim"
        "lspkind-nvim"
        "lspsaga-nvim"
        "lualine-nvim"
        "material-nvim"
        "mini-nvim"
        "mkdir-nvim"
        "neo-tree-nvim"
        "neoconf-nvim"
        "neodev-nvim"
        "neogen"
        "neorg-interim-ls"
        "nightfox-nvim"
        "nim-vim"
        "noice-nvim"
        "none-ls-nvim"
        "notifier-nvim"
        "nui-nvim"
        "null-ls-nvim"
        "nvim-autopairs"
        "nvim-biscuits"
        "nvim-cmp"
        "nvim-colorizer-lua"
        "nvim-dap"
        "nvim-dap-ui"
        "nvim-expand-expr"
        "nvim-hlslens"
        "nvim-lightbulb"
        "nvim-lint"
        "nvim-lsp-file-operations"
        "nvim-lspconfig"
        "nvim-moonwalk"
        "nvim-navic"
        "nvim-nonicons"
        "nvim-notify"
        "nvim-numbertoggle"
        "nvim-osc52"
        "nvim-parinfer"
        "nvim-scrollbar"
        "nvim-tree-lua"
        "nvim-treesitter"
        "nvim-treesitter-textsubjects"
        "nvim-ts-autotag"
        "nvim-ts-context-commentstring"
        "nvim-web-devicons"
        "orgmode"
        "package-info-nvim"
        "plenary-nvim"
        "popup-nvim"
        "presence-nvim"
        "pretty-fold-nvim"
        "purescript-vim"
        "rainbow-delimiters-nvim"
        "range-highlight-nvim"
        "refactoring-nvim"
        "remember-nvim"
        "satellite-nvim"
        "sort-nvim"
        "specs-nvim"
        "spellsitter-nvim"
        "sqlite-lua"
        "stabilize-nvim"
        "staline-nvim"
        "tabby-nvim"
        "telescope-dap-nvim"
        "telescope-frecency-nvim"
        "telescope-fzy-native-nvim"
        "telescope-nvim"
        "telescope-symbols-nvim"
        "telescope-ui-select-nvim"
        "telescope-zf-native-nvim"
        "todo-comments-nvim"
        "toggleterm-nvim"
        "trouble-nvim"
        "typescript-nvim"
        "vim-coffee-script"
        "vim-parinfer"
        "virtual-types-nvim"
        "which-key-nvim"
        "yaml-companion-nvim"
        "yanky-nvim"
        "yuck-vim"
      ]
      (name: [
        "vimPlugins"
        name
      ]);
  yaziPlugins =
    lib.genAttrs
      [
        "allmytoes"
        "bookmarks"
        "bypass"
        "compress"
        "glow"
        "gvfs"
        "lazygit"
        "mediainfo"
        "miller"
        "ouch"
        "projects"
        "relative-motions"
        "rich-preview"
        "rsync"
        "starship"
        "sudo"
        "yatline"
      ]
      (name: [
        "yaziPlugins"
        name
      ]);
  ysfx = [ "ysfx" ];
  zl-audio = {
    equalizer = [ "zlequalizer" ];
    compressor = [ "zlcompressor" ];
    splitter = [ "zlsplitter" ];
  };
  zlint-bin = [ "zlint-zig" ];
  zrythm = [ "zrythm" ];
  # keep-sorted end
}
