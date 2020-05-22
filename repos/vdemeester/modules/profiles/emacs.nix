{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.emacs;
  capture = pkgs.writeScriptBin "capture" ''
    #!${pkgs.stdenv.shell}
    emacsclient -s /run/user/1000/emacs/org -n -F '((name . "capture") (width . 150) (height . 90))' -e '(org-capture)'
  '';
  myEmacs = pkgs.emacs27.override { inherit (pkgs) imagemagick; withXwidgets = cfg.withXwidgets; };
in
{
  options = {
    profiles.emacs = {
      enable = mkEnableOption "Enable emacs profile";
      capture = mkEnableOption "Enable capture script(s)";
      daemonService = mkOption {
        default = true;
        description = "Enable emacs daemon service";
        type = types.bool;
      };
      withXwidgets = mkEnableOption "Enable Xwidgets in emacs build";
      texlive = mkOption {
        default = true;
        description = "Enable Texlive";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    {
      home.file.".local/share/applications/org-protocol.desktop".source = ./assets/xorg/org-protocol.desktop;
      home.file.".local/share/applications/ec.desktop".source = ./assets/xorg/ec.desktop;
      home.file.".local/share/applications/capture.desktop".source = ./assets/xorg/capture.desktop;
      home.packages = with pkgs; [
        ditaa
        graphviz
        pandoc
        zip
        hunspell
        hunspellDicts.en_US-large
        hunspellDicts.en_GB-ize
        hunspellDicts.fr-any
        nixpkgs-fmt
      ];
      home.sessionVariables = {
        EDITOR = "et";
        ALTERNATE_EDITOR = "et";
      };
      programs.emacs = {
        enable = true;
        package = myEmacs;
        extraPackages = epkgs: with epkgs; [
          ace-window
          aggressive-indent
          async
          avy
          bbdb
          beginend
          pkgs.bookmark-plus
          company
          company-emoji
          company-go
          dash
          delight
          dired-collapse
          dired-git-info
          dired-quick-sort
          dired-narrow
          dired-rsync
          pkgs.dired-plus
          direnv
          dockerfile-mode
          easy-kill
          esup
          expand-region
          flycheck
          flycheck-golangci-lint
          git-annex
          git-commit
          gitattributes-mode
          gitconfig-mode
          gitignore-mode
          github-review
          goto-last-change
          hardhat
          helpful
          highlight
          highlight-indentation
          highlight-numbers
          ibuffer-vc
          iedit
          json-mode
          markdown-mode
          #modus-operandi-theme
          #modus-vivendi-theme
          mpdel
          multiple-cursors
          nixpkgs-fmt
          no-littering
          ob-async
          ob-go
          ob-http
          orgit
          org-plus-contrib
          org-capture-pop-frame
          org-gcal
          org-ref
          org-super-agenda
          org-web-tools
          ox-pandoc
          pandoc-mode
          projectile
          projectile-ripgrep
          pdf-tools
          python-mode
          rainbow-delimiters
          rainbow-mode
          region-bindings-mode
          ripgrep
          rg
          try
          visual-fill-column
          visual-regexp
          web-mode
          wgrep
          with-editor
          xterm-color
          yaml-mode
          darkroom
          eshell-prompt-extras
          esh-autosuggest
          forge
          go-mode
          magit
          magit-annex
          magit-popup
          minions
          moody
          mwim
          nix-buffer
          nix-mode
          org-super-agenda
          org-tree-slide
          shr-tag-pre-highlight
          ssh-config-mode
          smartparens
          symbol-overlay
          undo-tree
          use-package
          # Highly experimental
          vterm
          gotest
        ];
      };
    }
    (
      mkIf config.profiles.emacs.capture {
        home.packages = with pkgs; [ wmctrl capture ];
      }
    )
    (
      mkIf config.services.gpg-agent.enable {
        #services.gpg-agent.extraConfig = ''
        #  allow-emacs-pinentry
        #'';
      }
    )
    (
      mkIf cfg.texlive {
        home.packages = with pkgs; [ texlive.combined.scheme-full ];
      }
    )
    (
      mkIf cfg.daemonService {
        services.emacs-server = {
          enable = true;
          package = myEmacs;
          name = "org";
          shell = pkgs.zsh + "/bin/zsh -i -c";
          extraOptions = "--dump-file=${config.home.homeDirectory}/.config/emacs/emacs.pdmp";
        };
      }
    )
  ]);
}
