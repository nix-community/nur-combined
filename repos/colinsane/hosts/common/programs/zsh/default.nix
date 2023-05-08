{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.sane.zsh;
  # powerlevel10k prompt config
  # p10k.zsh is the auto-generated config, and i overwrite those defaults here, below.
  p10k-overrides = ''
    # powerlevel10k launches a gitstatusd daemon to accelerate git prompt queries.
    # this keeps open file handles for any git repo i touch for 60 minutes (by default).
    # that prevents unmounting whatever device the git repo is on -- particularly problematic for ~/private.
    # i can disable gitstatusd and get slower fallback git queries:
    # - either universally
    # - or selectively by path
    # see: <https://github.com/romkatv/powerlevel10k/issues/246>
    typeset -g POWERLEVEL9K_VCS_DISABLED_DIR_PATTERN='(/home/colin/private/*|/home/colin/knowledge/*)'
    # typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true

    # show user@host also when logged into the current machine.
    # default behavior is to show it only over ssh.
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION='$P9K_CONTENT'
  '';

  prezto-init = ''
    source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${pkgs.zsh-prezto}/share/zsh-prezto/init.zsh
  '';
in
{
  options = {
    sane.zsh = {
      showDeadlines = mkOption {
        type = types.bool;
        default = true;
        description = "show upcoming deadlines (frommy PKM) upon shell init";
      };
    };
  };

  config = mkMerge [
    ({
      sane.programs.zsh = {
        persist.plaintext = [
          # we don't need to full zsh dir -- just the history file --
          # but zsh will sometimes backup the history file and we get fewer errors if we do proper mounts instead of symlinks.
          # TODO: should be private?
          ".local/share/zsh"
          # cache gitstatus otherwise p10k fetched it from the net EVERY BOOT
          ".cache/gitstatus"
        ];

        # zsh/prezto complains if zshrc doesn't exist; but it does allow an "empty" file.
        fs.".config/zsh/.zshrc".symlink.text = "# ";

        # prezto = oh-my-zsh fork; controls prompt, auto-completion, etc.
        # see: https://github.com/sorin-ionescu/prezto
        # i believe this file is auto-sourced by the prezto init.zsh script.
        fs.".config/zsh/.zpreztorc".symlink.text = ''
          zstyle ':prezto:*:*' color 'yes'

          # modules (they ship with prezto):
          # ENVIRONMENT: configures jobs to persist after shell exit; other basic niceties
          # TERMINAL: auto-titles terminal (e.g. based on cwd)
          # EDITOR: configures shortcuts like Ctrl+U=undo, Ctrl+L=clear
          # HISTORY: `history-stat` alias, setopts for good history defaults
          # DIRECTORY: sets AUTO_CD, adds `d` alias to list directory stack, and `1`-`9` to cd that far back the stack
          # SPECTRUM: helpers for term colors and styling. used by prompts? might be unnecessary
          # UTILITY: configures aliases like `ll`, `la`, disables globbing for things like rsync
          #   adds aliases like `get` to fetch a file. also adds `http-serve` alias??
          # COMPLETION: tab completion. requires `utility` module prior to loading
          # TODO: enable AUTO_PARAM_SLASH
          zstyle ':prezto:load' pmodule \
            'environment' \
            'terminal' \
            'editor' \
            'history' \
            'directory' \
            'spectrum' \
            'utility' \
            'completion' \
            'prompt'

          # default keymap. try also `vicmd` (vim normal mode, AKA "cmd mode") or `vi`.
          zstyle ':prezto:module:editor' key-bindings 'emacs'

          zstyle ':prezto:module:prompt' theme 'powerlevel10k'

          # disable `mv` confirmation (and `rm`, too, unfortunately)
          zstyle ':prezto:module:utility' safe-ops 'no'
        '';
      };
    })
    (mkIf config.sane.programs.zsh.enabled {
      # enable zsh completions
      environment.pathsToLink = [ "/share/zsh" ];

      programs.zsh = {
        enable = true;
        histFile = "$HOME/.local/share/zsh/history";
        shellAliases = {
          ":q" = "exit";
          # common typos
          "cd.." = "cd ..";
          "cd../" = "cd ../";
        };
        setOptions = [
          # defaults:
          "HIST_IGNORE_DUPS"
          "SHARE_HISTORY"
          "HIST_FCNTL_LOCK"
          # disable `rm *` confirmations
          "rmstarsilent"
        ];

        # .zshenv config:
        shellInit = ''
          ZDOTDIR=$HOME/.config/zsh
        '';

        # .zshrc config:
        interactiveShellInit =
          (builtins.readFile ./p10k.zsh)
        + p10k-overrides
        + prezto-init
        + ''
          # zmv is a way to do rich moves/renames, with pattern matching/substitution.
          # see for an example: <https://filipe.kiss.ink/zmv-zsh-rename/>
          autoload -Uz zmv

          HISTORY_IGNORE='(sane-shutdown *|sane-reboot *|rm *|nixos-rebuild.* switch)'

          # extra aliases
          # TODO: move to `shellAliases` config?
          function nd() {
            mkdir -p "$1";
            pushd "$1";
          }
        ''
        + lib.optionalString cfg.showDeadlines ''
          ${pkgs.sane-scripts}/bin/sane-deadlines
        ''
        + ''
          # auto-cd into any of these dirs by typing them and pressing 'enter':
          hash -d 3rd="/home/colin/dev/3rd"
          hash -d dev="/home/colin/dev"
          hash -d knowledge="/home/colin/knowledge"
          hash -d nixos="/home/colin/nixos"
          hash -d nixpkgs="/home/colin/dev/3rd/nixpkgs"
          hash -d ref="/home/colin/ref"
          hash -d secrets="/home/colin/knowledge/secrets"
          hash -d tmp="/home/colin/tmp"
          hash -d uninsane="/home/colin/dev/uninsane"
          hash -d Videos="/home/colin/Videos"
        '';

        syntaxHighlighting.enable = true;
        vteIntegration = true;
      };

      # enable a command-not-found hook to show nix packages that might provide the binary typed.
      programs.nix-index.enable = true;
      programs.command-not-found.enable = false;  #< mutually exclusive with nix-index
    })
  ];
}
