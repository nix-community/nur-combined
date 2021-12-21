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
    alpha-nvim = true;

    calltree-nvim = true;

    highlight-current-n-nvim = true;

    vacuumline-nvim = true;

    vgit-nvim = true;

    zen-mode-nvim = true;
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

    bullets-vim = [ mit ];

    calltree-nvim = [ mit ];

    format-nvim = [ mit ];

    goimpl-nvim = [ mit ];

    null-ls-nvim = [ publicDomain ];

    nvim-base16-lua = [ mit ];

    nvim-deus = [ gpl3Plus ];

    nvim-luapad = [ gpl3Only ];

    nvim-pqf = [ mpl20 ];

    nvim-revJ-lua = [ vim ];

    nvim-srcerite = [ gpl3Plus ];

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
    alpha-nvim = [ nvim-web-devicons ];

    apprentice-nvim = [ lush-nvim ];

    auto-pandoc-nvim = [ plenary-nvim ];

    cmp-npm = [ plenary-nvim ];

    cmp-tmux = [ nvim-cmp ];

    code-runner-nvim = [ plenary-nvim ];

    codeschool-nvim = [ lush-nvim ];

    express-line-nvim = [ plenary-nvim ];

    flutter-tools-nvim = [ plenary-nvim ];

    follow-md-links-nvim = [ nvim-treesitter ];

    fuzzy-nvim = [ plenary-nvim ];

    gloombuddy = [ colorbuddy-nvim ];

    goimpl-nvim = [ nvim-treesitter telescope-nvim ];

    gruvbuddy-nvim = [ colorbuddy-nvim ];

    gruvy = [ lush-nvim ];

    jester = [ nvim-treesitter ];

    lspactions = [ plenary-nvim popup-nvim self.astronauta-nvim ];

    neogen = [ nvim-treesitter ];

    neorg = [ plenary-nvim ];

    nlsp-settings-nvim = [ nvim-lspconfig ];

    nvim-biscuits = [ nvim-treesitter ];

    nvim-comment-frame = [ nvim-treesitter ];

    nvim-go = [ plenary-nvim popup-nvim ];

    nvim-lsp-installer = [ nvim-lspconfig ];

    nvim-lspupdate = [ nvim-lspconfig ];

    nvim-magic = [ plenary-nvim nui-nvim ];

    nvim-rdark = [ colorbuddy-nvim ];

    nvim-revJ-lua = [ self.vim-textobj-parameter ];

    nvim-spectre = [ plenary-nvim ];

    nvim-treesitter-textsubjects = [ nvim-treesitter ];

    nvim-ts-autotag = [ nvim-treesitter ];

    nvim-ts-context-commentstring = [ nvim-treesitter ];

    one-small-step-for-vimkind = [ nvim-dap ];

    onebuddy = [ colorbuddy-nvim ];

    renamer-nvim = [ plenary-nvim ];

    tabline-framework-nvim = [ nvim-web-devicons ];

    tabout-nvim = [ nvim-treesitter ];

    telescope-bibtex-nvim = [ telescope-nvim ];

    telescope-heading-nvim = [ telescope-nvim ];

    telescope-zoxide = [ telescope-nvim ];

    vacuumline-nvim = [ galaxyline-nvim ];

    vgit-nvim = [ plenary-nvim ];

    vim-textobj-parameter = [ vim-textobj-user ];

    virtual-types-nvim = [ nvim-lspconfig ];
  });

  /*
   * Add other overrides here.
   */
  otherOverrides = self: super:
  {
    feline-nvim-develop = super.feline-nvim-develop.overrideAttrs (old: {
      patches = (old.patches or []) ++ lib.optionals (lib.versionOlder "2021-12-19" old.version) [
        # https://github.com/famiu/feline.nvim/pull/179
        (final.fetchpatch {
          url = "https://github.com/zbirenbaum/feline.nvim/commit/d62d9ec923fe76da27f5ac7000b2a506b035740d.patch";
          sha256 = "sha256-fLa6za0Srm/gnVPlPgs11+2cxhj7hitgUhlHu2jc2+s=";
        })
      ];
    });

    nvim-papadark = super.themer-lua;
  };
in

{
  vimExtraPlugins = prev.vimExtraPlugins.extend (lib.composeManyExtensions [
    markBrokenPackages
    fixLicenses
    fixDependencies
    otherOverrides
  ]);
}
