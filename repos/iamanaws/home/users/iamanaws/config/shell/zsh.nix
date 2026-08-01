{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g default-shell ${pkgs.zsh}/bin/zsh
      set -g default-terminal "screen-256color"
    '';
  };

  programs.zsh = {
    enable = true;
    completionInit = "autoload -Uz compinit";
    defaultKeymap = "emacs";
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    history.expireDuplicatesFirst = true;
    history.path = "$ZDOTDIR/.zsh_history";
    history.save = 10000;
    history.size = 10000;

    shellAliases = {
    };

    initContent =
      let
        # initExtraFirst = lib.mkOrder 500 "";
        # initExtraAfter = lib.mkOrder 1500 "";

        zshBefore = lib.mkOrder 550 "\n
        zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'\n
        zstyle ':completion:*' list-colors ''\n
      ";
        # zstyle ':completion:*' completer _list _complete _ignored _correct _approximate
        # zstyle ':completion:*' max-errors 4 numeric
        # zstyle ':completion:*' menu select=2
        # zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

        zshConfig = "
        # Directory trimming
        PROMPT_DIRTRIM=2

        # Deny overwriting
        set -o noclobber

        fet.sh

        function parse_git_branch() {
          git branch 2> /dev/null | sed -n -e 's/^\\* \\(.*\\)/(\\1) /p'
        }

        function parse_nix_shell() {
          if [[ -n \"\$IN_NIX_SHELL\" ]]; then
            echo \" \"
          fi
        }

        COLOR_USR=\$'%F{15}'   # User color set to white
        COLOR_DIR=\$'%F{12}'   # Directory color set to blue
        COLOR_GIT=\$'%F{135}'  # Git color set to purple
        COLOR_DEF=\$'%F{15}'   # Default prompt color set to white
        COLOR_NIX=\$'%F{81}'   # Nix shell indicator color turquoise

        setopt PROMPT_SUBST

        export PROMPT='%B\${COLOR_DIR}%2~ \${COLOR_GIT}$(parse_git_branch)\${COLOR_NIX}$(parse_nix_shell)%b'$'\\n''\${COLOR_DEF}$ '
      ";

      in
      lib.mkMerge [
        zshBefore
        zshConfig
      ];

    profileExtra = "\n
      eval \"$(/opt/homebrew/bin/brew shellenv)\"\n\n
      # Added by Toolbox App\n
      export PATH=\"$PATH:/Users/angel/Library/Application Support/JetBrains/Toolbox/scripts\"\n
    ";
  };
}
