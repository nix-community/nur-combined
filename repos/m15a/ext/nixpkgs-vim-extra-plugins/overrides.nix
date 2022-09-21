final: prev:

let
  inherit (final) lib;

  /*
   * Mark broken packages here.
   */
  markBrokenPackages = self: super:
  lib.mapAttrs (attrName: broken: super.${attrName}.overrideAttrs (old: {
    meta = old.meta // { inherit broken; };
  }))
  {
    SmoothCursor-nvim = true;

    go-nvim = true;

    highlight-current-n-nvim = true;

    incline-nvim = true;

    snippet-converter-nvim = true;

    vacuumline-nvim = true;

    vgit-nvim = true;

    unruly-worker = true;
  };

  /*
   * Add licenses if missing or incorrect in generated ./pkgs/vim-plugins.nix.
   */
  fixLicenses = self: super:
  lib.mapAttrs (attrName: license: super.${attrName}.overrideAttrs (old: {
    meta = old.meta // { inherit license; };
  })) (with lib.licenses;
  {
    ariake-vim-colors = [ mit ];

    bats-vim = [ vim ];

    christmas-vim = [ mit ];

    coc-tailwind-intellisense = [ mit ];

    distant-nvim = [ asl20 mit ];

    goimpl-nvim = [ mit ];

    null-ls-nvim = [ publicDomain ];

    nvim-base16-lua = [ mit ];

    nvim-cartographer = [ gpl3Plus ];

    nvim-deus = [ gpl3Plus ];

    nvim-pqf = [ mpl20 ];

    nvim-remote-containers = [rec {
      shortName = fullName;
      fullName = "jamestthompson3's modified MIT License";
      url = "https://github.com/jamestthompson3/nvim-remote-containers/blob/master/LICENSE";
      free = true;
      redistributable = true;
      deprecated = false;
    }];

    nvim-revJ-lua = [ vim ];

    nvim-srcerite = [ gpl3Plus ];

    nvim-window = [ mpl20 ];

    osc-nvim = [ mit ];

    vim-emacscommandline = [ vim ];

    vim-hy = [ vim ];

    vim-textobj-indent = [ mit ];

    vim-textobj-parameter = [ mit ];
  });

  /*
   * Add dependencies to vim plugins if missing or incorrect in generated ./pkgs/vim-plugins.nix.
   */
  fixDependencies = self: super:
  lib.mapAttrs (attrName: dependencies: super.${attrName}.overrideAttrs (_: {
    inherit dependencies;
  })) (with final.vimPlugins;
  {
    apprentice-nvim = [ lush-nvim ];

    auto-pandoc-nvim = [ plenary-nvim ];

    code-runner-nvim = [ plenary-nvim ];

    codeschool-nvim = [ lush-nvim ];

    express-line-nvim = [ plenary-nvim ];

    follow-md-links-nvim = [ nvim-treesitter ];

    fuzzy-nvim = [ plenary-nvim ];

    github-colors = [ nvim-treesitter ];

    gloombuddy = [ colorbuddy-nvim ];

    go-nvim = [ nvim-treesitter ];

    goimpl-nvim = [ nvim-treesitter telescope-nvim ];

    gruvbuddy-nvim = [ colorbuddy-nvim ];

    gruvy = [ lush-nvim ];

    jester = [ nvim-treesitter ];

    lspactions = [ plenary-nvim popup-nvim ];

    lspactions-nvim06-compatible = [ plenary-nvim popup-nvim self.astronauta-nvim ];

    navigator-lua = [ nvim-lspconfig self.guihua-lua ];

    neogen = [ nvim-treesitter ];

    nlsp-settings-nvim = [ nvim-lspconfig ];

    nvim-comment-frame = [ nvim-treesitter ];

    nvim-go = [ plenary-nvim popup-nvim ];

    nvim-lsp-basics = [ nvim-lspconfig ];

    nvim-lspfuzzy = [ fzfWrapper ];

    nvim-lsp-installer = [ nvim-lspconfig ];

    nvim-lspupdate = [ nvim-lspconfig ];

    nvim-magic = [ plenary-nvim nui-nvim ];

    nvim-rdark = [ colorbuddy-nvim ];

    nvim-revJ-lua = [ self.vim-textobj-parameter ];

    nvim-spectre = [ plenary-nvim ];

    nvim-treesitter-textsubjects = [ nvim-treesitter ];

    nvim-treehopper = [ nvim-treesitter ];

    nvim-ts-context-commentstring = [ nvim-treesitter ];

    one-small-step-for-vimkind = [ nvim-dap ];

    onebuddy = [ colorbuddy-nvim ];

    reaper-nvim = [ self.osc-nvim ];

    sqls-nvim = [ nvim-lspconfig ];

    startup-nvim = [ telescope-nvim ];

    tabline-framework-nvim = [ nvim-web-devicons ];

    tabout-nvim = [ nvim-treesitter ];

    telescope-bibtex-nvim = [ telescope-nvim ];

    telescope-command-palette-nvim = [ telescope-nvim ];

    telescope-heading-nvim = [ telescope-nvim ];

    telescope-tmuxinator-nvim = [ telescope-nvim ];

    vacuumline-nvim = [ galaxyline-nvim ];

    vgit-nvim = [ plenary-nvim ];

    vim-textobj-parameter = [ vim-textobj-user ];

    virtual-types-nvim = [ nvim-lspconfig ];

    yabs-nvim = [ plenary-nvim ];

    zenbones-nvim = [ lush-nvim ];
  });

  /*
   * Add plugins that were once here but now officially maintained.
   */
  onceHereButNowOfficiallyMaintainedPlugins = self: super:
  {
    inherit (final.vimPlugins)
    cmp-tmux
    kanagawa-nvim
    litee-nvim
    lua-dev-nvim
    mini-nvim
    nvim-ts-autotag
    # onedark-nvim is an alias to onedark-pro-nvim.
    # See https://github.com/NixOS/nixpkgs/pull/153045#discussion_r781641557
    # onedark-nvim
    project-nvim
    renamer-nvim
    surround-nvim
    nvim-neoclip-lua
    nvcode-color-schemes-vim
    cmp-npm
    nightfox-nvim
    nvim-highlite
    lean-nvim
    galaxyline-nvim
    rest-nvim
    aniseed
    conjure
    nvim-base16
    vim-illuminate
    nvim-lsputils
    one-nvim
    harpoon
    vim-apm
    neogit
    scrollbar-nvim
    bufferline-nvim
    flutter-tools-nvim
    luatab-nvim
    nordic-nvim
    presence-nvim
    urlview-nvim
    SchemaStore-nvim
    kommentary
    snap
    marks-nvim
    coc-svelte
    nvim-biscuits
    nvim-snippy
    bullets-vim
    nvim-scrollview
    specs-nvim
    gruvbox-nvim
    nvim-lastplace
    vim-svelte
    git-blame-nvim
    cmp-spell
    bufdelete-nvim
    falcon
    lsp-colors-nvim
    todo-comments-nvim
    tokyonight-nvim
    trouble-nvim
    twilight-nvim
    which-key-nvim
    zen-mode-nvim
    wilder-nvim
    nvim-jqx
    nvim-peekup
    fzf-lsp-nvim
    lightspeed-nvim
    copilot-vim
    dashboard-nvim
    zephyr-nvim
    alpha-nvim
    editorconfig-nvim
    cmp-buffer
    cmp-nvim-lsp
    cmp-nvim-lua
    cmp-path
    nvim-cmp
    coc-tailwindcss
    fzf-lua
    nvim-solarized-lua
    fidget-nvim
    venn-nvim
    nterm-nvim
    nvim-lsp-ts-utils
    telescope-zoxide
    neoscroll-nvim
    lazygit-nvim
    tabline-nvim
    nvim-bqf
    nvim-hlslens
    rnvimr
    nvim-config-local
    nvim-lightbulb
    substrata-nvim
    nvim-tree-lua
    nvim-web-devicons
    gitsigns-nvim
    spellsitter-nvim
    cmp-rg
    cmp-under-comparator
    indent-blankline-nvim
    stabilize-nvim
    material-nvim
    better-escape-nvim
    jellybeans-nvim
    nvim-dap
    nvim-lint
    formatter-nvim
    oceanic-next
    zk-nvim
    numb-nvim
    nvim-lspconfig
    nvim-terminal-lua
    snippets-nvim
    FTerm-nvim
    Navigator-nvim
    lsp-status-nvim
    plenary-nvim
    popup-nvim
    lualine-nvim
    neorg
    orgmode
    telescope-media-files-nvim
    telescope-nvim
    nvim-treesitter
    nvim-treesitter-textobjects
    neuron-nvim
    onedarkpro-nvim
    diaglist-nvim
    nvim-ts-rainbow
    cmp-git
    hop-nvim
    octo-nvim
    cmp-nvim-ultisnips
    neon
    nvim-luapad
    aurora
    cmp-dap
    nvim-dap-ui
    nvim-notify
    vim-ultest
    hotpot-nvim
    lush-nvim
    auto-session
    goto-preview
    barbar-nvim
    gitlinker-nvim
    edge
    everforest
    gruvbox-material
    sonokai
    nvim-gdb
    neoformat
    nvim-metals
    nord-nvim
    rust-tools-nvim
    symbols-outline-nvim
    diffview-nvim
    winshift-nvim
    aerial-nvim
    dressing-nvim
    cheatsheet-nvim
    Shade-nvim
    lir-nvim
    nvim-comment
    colorbuddy-nvim
    nlua-nvim
    train-nvim
    vim-code-dark
    registers-nvim
    cmp-fuzzy-buffer
    cmp-fuzzy-path
    # NOTE: `nix flake check` fails since tabline is unfree package.
    # cmp-tabnine
    nvim-fzf
    package-info-nvim
    packer-nvim
    nvim-code-action-menu
    nvim-autopairs
    range-highlight-nvim
    nvim-cursorline
    nvim-nonicons
    vim-printer
    ;
  } // (with final.vimPlugins; {
    # FIXME: error: Alias TrueZen-nvim is still in vim-plugins
    # true-zen-nvim = TrueZen-nvim;
    coq-nvim = coq_nvim;
    nvim-context-vt = nvim_context_vt;
    cmp-luasnip = cmp_luasnip;
    lsp-lines-nvim = lsp_lines-nvim;
    lsp-extensions-nvim = lsp_extensions-nvim;
    lsp-signature-nvim = lsp_signature-nvim;
  });

  /*
   * Add other overrides here.
   */
  otherOverrides = self: super:
  {
    feline-nvim = super.feline-nvim.overrideAttrs (old: {
      patches = (old.patches or []) ++ lib.optionals (lib.versionOlder old.version "2021-12-19") [
        # https://github.com/famiu/feline.nvim/pull/179
        (final.fetchpatch {
          url = "https://github.com/zbirenbaum/feline.nvim/commit/d62d9ec923fe76da27f5ac7000b2a506b035740d.patch";
          sha256 = "sha256-fLa6za0Srm/gnVPlPgs11+2cxhj7hitgUhlHu2jc2+s=";
        })
      ];
    });

    glow-nvim = super.glow-nvim.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        # https://github.com/ellisonleao/glow.nvim/pull/80
        (final.fetchpatch {
          url = "https://github.com/ellisonleao/glow.nvim/pull/80/commits/16a348ffa8022945f735caf708c2bd601b08272c.patch";
          sha256 = "sha256-fljlBTHcoPjnavF37yoIs3zrZ3+iOX6oQ0e20AKtNI8=";
        })
      ];
    });

    guihua-lua = super.guihua-lua.overrideAttrs (old: {
      buildPhase = ''
        (
          cd lua/fzy
          make
        )
      '';
    });

    mdeval-nvim = super.mdeval-nvim.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        sed -Ei lua/mdeval.lua \
            -e 's@(get_command\(string\.format\(")mkdir@\1${final.coreutils}/bin/mkdir@' \
            -e 's@(get_command\(string\.format\(")rm@\1${final.coreutils}/bin/rm@' \
            -e 's@(2>&1; )echo@\1${final.coreutils}/bin/echo@'
      '';
    });

    nvim-papadark = self.themer-lua;

    feline-nvim-develop = self.feline-nvim;
  };
in

{
  vimExtraPlugins = prev.vimExtraPlugins.extend (lib.composeManyExtensions [
    markBrokenPackages
    fixLicenses
    fixDependencies
    onceHereButNowOfficiallyMaintainedPlugins
    otherOverrides
  ]);
}
