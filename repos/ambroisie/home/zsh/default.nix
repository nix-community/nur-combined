{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.zsh;
in
{
  options.my.home.zsh = with lib.my; {
    enable = mkDisableOption "zsh configuration";
  };

  config.programs.zsh = lib.mkIf cfg.enable {
    enable = true;
    dotDir = ".config/zsh"; # Don't clutter $HOME
    enableCompletion = true;

    history = {
      size = 500000;
      ignoreSpace = true;
      ignoreDups = true;
      share = true;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };

    plugins = with pkgs; [
      {
        name = "fast-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zdharma";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "sha256-DWVFBoICroKaKgByLmDEo4O+xo6eA8YO792g8t8R7kA=";
        };
      }
      {
        name = "agkozak-zsh-prompt";
        src = fetchFromGitHub {
          owner = "agkozak";
          repo = "agkozak-zsh-prompt";
          rev = "v3.9.0";
          sha256 = "sha256-VTRL+8ph2eI7iPht15epkLggAgtLGxB3DORFTW5GrhE=";
        };
      }
    ];

    # Modal editing is life, but CLI benefits from emacs gymnastics
    defaultKeymap = "emacs";

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
  config.programs.fzf = lib.mkIf cfg.enable {
    enable = true;
    enableZshIntegration = true;
  };

  config.programs.dircolors = lib.mkIf cfg.enable {
    enable = true;
  };
}
