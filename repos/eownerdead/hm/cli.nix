{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.eownerdead.cli.enable = lib.mkEnableOption "Enable useful CLI environment";

  config = lib.mkIf config.eownerdead.cli.enable {
    home = {
      packages = with pkgs; [
        bc
        file
        tree
        zip
        unzip
        p7zip
        psmisc
        lsof
        pciutils
        usbutils
        inetutils
        dig.dnsutils
        sharutils
        cheat
        xh # Friendly curl alternative
      ];
      persistence."/nix/persist".directories =
        lib.mkIf config.eownerdead.imperm.enable
          [
            ".local/share/direnv"
          ];
    };

    programs = {
      bash = {
        enable = true;
        enableVteIntegration = true;
        historyControl = [
          "erasedups"
          "ignoredups"
          "ignorespace"
        ];
        historyFile = lib.mkIf config.eownerdead.imperm.enable "${config.eownerdead.imperm.path}/.config/bash/history";
      };
      readline = {
        enable = true;
        bindings = {
          "\\C-h" = "backword-delete-char";
          "\\eh" = "backword-kill-word";
        };
        variables = {
          colored-completion-prefix = true;
          colored-stats = true;
          completion-ignore-case = true;
          completion-map-case = true;
          mark-symlinked-directories = true;
          search-ignore-case = true;
          show-all-if-ambiguous = true;
          skip-completed-text = true;
          visible-stats = true;
        };
      };
      bat.enable = true;
      eza = {
        enable = true;
        enableBashIntegration = true;
        git = true;
        icons = "auto";
      };
      fd = {
        enable = true;
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      ripgrep.enable = true;
      zoxide = {
        enable = true;
        enableBashIntegration = true;
        options = [
          "--cmd"
          "cd"
        ];
      };
      jq.enable = true;
      tealdeer = {
        enable = true;
        settings = {
          display = {
            show_title = true;
            use_pager = true;
          };
          directories.cache_dir = lib.mkIf config.eownerdead.imperm.enable "${config.eownerdead.imperm.path}/.cache/tealdeer/";
        };
      };
    };
  };
}
