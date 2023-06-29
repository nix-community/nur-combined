# zsh files/init order
# - see `man zsh` => "STARTUP/SHUTDOWN FILES"
# - /etc/zshenv
# - $ZDOTDIR/.zshenv
# - if login shell:
#   - /etc/zprofile
#   - $ZDOTDIR/.zprofile
# - if interactive:
#   - /etc/zshrc
#   - $ZDOTDIR/.zshrc
# - if login (again):
#   - /etc/zlogin
#   - ZDOTDIR/.zlogin
# - at exit:
#   - $ZDOTDIR/.zlogout
#   - /etc/zlogout

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
        description = "show upcoming deadlines (from my PKM) upon shell init";
      };
    };
  };

  config = mkMerge [
    ({
      sane.programs.zsh = {
        persist.private = [
          # we don't need to full zsh dir -- just the history file --
          # but zsh will sometimes backup the history file and symlinking just the file messes things up
          ".local/share/zsh"
        ];
        persist.plaintext = [
          # cache gitstatus otherwise p10k fetches it from the net EVERY BOOT
          ".cache/gitstatus"
        ];

        fs.".config/zsh/.zshrc".symlink.text = ''
          # zsh/prezto complains if zshrc doesn't exist or is empty;
          # preserve this comment to prevent that from ever happening.
        '' + lib.optionalString cfg.showDeadlines ''
          ${pkgs.sane-scripts.deadlines}/bin/sane-deadlines
        '' + ''
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

        # prezto = oh-my-zsh fork; controls prompt, auto-completion, etc.
        # see: https://github.com/sorin-ionescu/prezto
        # this file is auto-sourced by the prezto init.zsh script.
        # TODO: i should work to move away from prezto:
        # - it's FUCKING SLOW to initialize (that might also be powerlevel10k tho)
        # - it messes with my other `setopt`s
        fs.".config/zsh/.zpreztorc".symlink.text = ''
          zstyle ':prezto:*:*' color 'yes'
          zstyle ':prezto:module:utility' correct 'no'  # prezto: don't setopt CORRECT

          # modules (they ship with prezto):
          # ENVIRONMENT: configures jobs to persist after shell exit; other basic niceties
          # TERMINAL: auto-titles terminal (e.g. based on cwd)
          # EDITOR: configures shortcuts like Ctrl+U=undo, Ctrl+L=clear
          # HISTORY: `history-stat` alias, setopts for good history defaults
          # DIRECTORY: sets AUTO_CD, adds `d` alias to list directory stack, and `1`-`9` to cd that far back the stack. also overrides CLOBBER and some other options
          # SPECTRUM: helpers for term colors and styling. used by prompts? might be unnecessary
          # UTILITY: configures aliases like `ll`, `la`, disables globbing for things like rsync
          #   adds aliases like `get` to fetch a file. also adds `http-serve` alias??
          # COMPLETION: tab completion. requires `utility` module prior to loading
          zstyle ':prezto:load' pmodule \
            'environment' \
            'terminal' \
            'editor' \
            'history' \
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
          # docs: `man zshoptions`
          # nixos defaults:
          "HIST_FCNTL_LOCK"
          "HIST_IGNORE_DUPS"
          "SHARE_HISTORY"
          # customizations:
          "AUTO_CD"  # type directory name to go there
          "AUTO_MENU"  # show auto-complete menu on double-tab
          "CDABLE_VARS"  # allow auto-cd to use my `hash` aliases -- not just immediate subdirs
          "CLOBBER"  # allow `foo > bar.txt` to overwrite bar.txt
          "NO_CORRECT"  # don't try to correct commands
          "PIPE_FAIL"  # when `cmd_a | cmd_b`, make $? be non-zero if *any* of cmd_a or cmd_b fail
          "RM_STAR_SILENT"  # disable `rm *` confirmations
        ];

        # .zshenv config:
        shellInit = ''
          ZDOTDIR=$HOME/.config/zsh
        '';

        # system-wide .zshrc config:
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
        '';

        syntaxHighlighting.enable = true;
        vteIntegration = true;
      };

      # enable a command-not-found hook to show nix packages that might provide the binary typed.
      # programs.nix-index.enableZshIntegration = true;
      programs.command-not-found.enable = false;
    })
  ];
}
