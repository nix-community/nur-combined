{ lib, ... }:

final: prev:

let
  overrides = self: super:
  {
    alpha-nvim = super.alpha-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        broken = true;
      });
    });
    calltree-nvim = super.calltree-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        broken = true;
      });
    });
    highlight-current-n-nvim = super.highlight-current-n-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        broken = true;
      });
    });
    vacuumline-nvim = super.vacuumline-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        broken = true;
      });
    });
    zen-mode-nvim = super.zen-mode-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        broken = true;
      });
    });
    vgit-nvim = super.vgit-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        broken = true;
      });
    });

    feline-nvim = super.feline-nvim.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        # https://github.com/famiu/feline.nvim/pull/179
        (final.fetchpatch {
          url = "https://github.com/zbirenbaum/feline.nvim/commit/d62d9ec923fe76da27f5ac7000b2a506b035740d.patch";
          sha256 = "sha256-fLa6za0Srm/gnVPlPgs11+2cxhj7hitgUhlHu2jc2+s=";
        })
      ];
    });

    lspactions = super.lspactions.overrideAttrs (_: {
      dependencies = with final.vimPlugins; [
        plenary-nvim
        popup-nvim
        self.astronauta-nvim
      ];
    });

    bats-vim = super.bats-vim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ vim ];
      });
    });

    bullets-vim = super.bullets-vim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ mit ];
      });
    });

    null-ls-nvim = super.null-ls-nvim.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ publicDomain ];
      });
    });

    vim-emacscommandline = super.vim-emacscommandline.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ vim ];
      });
    });

    vim-hy = super.vim-hy.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ vim ];
      });
    });

    vim-textobj-indent = super.vim-textobj-indent.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ mit ];
      });
    });

    nvim-srcerite = super.nvim-srcerite.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ gpl3Plus ];
      });
    });

    telescope-heading-nvim = super.telescope-heading-nvim.overrideAttrs (_: {
      dependencies = with final.vimPlugins; [
        telescope-nvim
      ];
    });

    telescope-bibtex-nvim = super.telescope-bibtex-nvim.overrideAttrs (_: {
      dependencies = with final.vimPlugins; [
        telescope-nvim
      ];
    });

    nvim-pqf = super.nvim-pqf.overrideAttrs (old: {
      meta = old.meta // ( with lib; {
        license = with licenses; [ mpl20 ];
      });
    });
  };
in

{ vimExtraPlugins = prev.vimExtraPlugins.extend overrides; }
