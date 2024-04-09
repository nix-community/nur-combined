{ pkgs, ... }: {
  home.packages = with pkgs; [ fortune file unzip p7zip cheat ];

  programs = {
    bash = {
      enable = true;
      initExtra = ''
        fortune
        echo
      '';
      historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    };
    readline = {
      enable = true;
      bindings = {
        "TAB" = "menu-complete";
        "\\C-h" = "backword-delete-char";
        "\\M-h" = "backword-kill-word";
        "\\e[A" = "history-search-backward";
        "\\e[B" = "history-search-forward";
      };
      variables = {
        colored-stats = true;
        completion-ignore-case = true;
        show-all-if-ambiguous = true;
        skip-completed-text = true;
      };
    };
    bat.enable = true;
    eza = {
      enable = true;
      enableAliases = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd" "cd" ];
    };
    jq.enable = true;
  };
}
