{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.zsh;
in
{
  options.my.home.zsh = with lib.my; {
    enable = mkDisableOption "zsh configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zsh-completions
    ];

    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh"; # Don't clutter $HOME
      enableCompletion = true;

      history = {
        size = 500000;
        save = 500000;
        extended = false;
        ignoreSpace = true;
        ignoreDups = true;
        share = false;
        path = "${config.xdg.dataHome}/zsh/zsh_history";
      };

      plugins = with pkgs; [
        {
          name = "fast-syntax-highlighting";
          file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
          src = pkgs.zsh-fast-syntax-highlighting;
        }
        {
          name = "agkozak-zsh-prompt";
          file = "share/zsh/site-functions/agkozak-zsh-prompt.plugin.zsh";
          src = pkgs.agkozak-zsh-prompt;
        }
      ];

      # Modal editing is life, but CLI benefits from emacs gymnastics
      defaultKeymap = "emacs";

      # Make those happen early to avoid doing double the work
      initExtraFirst =
        lib.optionalString config.my.home.tmux.enable ''
          # Launch tmux unless already inside one
          if [ -z "$TMUX" ]; then
            exec tmux new-session
          fi
        ''
      ;

      initExtra = lib.concatMapStrings builtins.readFile [
        ./completion-styles.zsh
        ./extra-mappings.zsh
        ./options.zsh
      ];

      localVariables = {
        # I like having the full path
        AGKOZAK_PROMPT_DIRTRIM = 0;
        # Because I *am* from EPITA
        AGKOZAK_PROMPT_CHAR = [ "42sh$" "42sh#" ":" ];
        # Easy on the eyes
        AGKOZAK_COLORS_BRANCH_STATUS = "magenta";
        # I don't like moving my eyes
        AGKOZAK_LEFT_PROMPT_ONLY = 1;
      };

      shellAliases = {
        # Sometime `gpg-agent` errors out...
        reset-agent = "gpg-connect-agent updatestartuptty /bye";
      };

      # Enable VTE integration when using one of the affected shells
      enableVteIntegration =
        builtins.any (name: config.my.home.terminal.program == name) [
          "termite"
        ];
    };

    # Fuzzy-wuzzy
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.dircolors = {
      enable = true;
    };
  };
}
