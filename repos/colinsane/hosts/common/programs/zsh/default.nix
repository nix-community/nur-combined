# zsh files/init order
# - see `man zsh` => "STARTUP/SHUTDOWN FILES"
# - /etc/zshenv
# - $ZDOTDIR/.zshenv
# - if login shell:
#   - /etc/zprofile
#   - $ZDOTDIR/.zprofile
# - if interactive:
#   - /etc/zshrc
#     -> /etc/zinputrc
#   - $ZDOTDIR/.zshrc
# - if login (again):
#   - /etc/zlogin
#   - ZDOTDIR/.zlogin
# - at exit:
#   - $ZDOTDIR/.zlogout
#   - /etc/zlogout

{ config, lib, ... }:

let
  cfg = config.sane.programs.zsh;
in
{
  imports = [
    ./starship.nix
  ];

  sane.programs.zsh = {
    configOption = with lib; mkOption {
      default = {};
      type = types.submodule {
        options.starship = mkOption {
          type = types.bool;
          default = true;
          description = "enable starship prompt";
        };
        options.guiIntegrations = mkOption {
          type = types.bool;
          default = config.sane.programs.guiApps.enabled;
          description = ''
            integrate with things like VTE, so that windowing systems can show the PWD in the title.
            drags in gtk+3.
          '';
        };
      };
    };

    # XXX(2025-12-08): statically compiled zsh loads faster than glibc
    # packageUnwrapped = pkgs.pkgsStatic.zsh;

    sandbox.enable = false;  # TODO: i could at least sandbox the prompt (starship)!
    persist.byStore.private = [
      # we don't need to full zsh dir -- just the history file --
      # but zsh will sometimes backup the history file and symlinking just the file messes things up
      ".local/share/zsh"
    ];

    fs.".config/zsh/.zshrc".symlink.target = ./zshrc;
  };


  # enable zsh completions
  environment.pathsToLink = lib.mkIf cfg.enabled [ "/share/zsh" ];

  programs.zsh = lib.mkIf cfg.enabled {
    enable = true;
    shellAliases = {
      ":fg" = "fg";
      ":q" = "exit";
      # common typos
      ":Q" = ":q";
      "cd.." = "cd ..";
      "cd../" = "cd ../";
      "eci5" = "exit";
      "ecit" = "exit";
      "eciy" = "exit";
      "exi5" = "exit";
      "exiy" = "exit";
      # overcome poor defaults
      "lsof" = "lsof -P";  #< lsof: use port *numbers*, not names
      "quit" = "exit";
      "tcpdump" = "tcpdump -n";  #< tcpdump: use port *numbers*, not names
    };
    setOptions = [
      # docs: `man zshoptions`
      # customizations:
      "AUTO_CD"  # type directory name to go there
      "AUTO_MENU"  # show auto-complete menu on double-tab
      "CDABLE_VARS"  # allow auto-cd to use my `hash` aliases -- not just immediate subdirs
      # "CLOBBER"  # (zsh default) allow `foo > bar.txt` to overwrite bar.txt
      # "CORRECT"  # try to correct typo'd commands
      # "EXTENDED_HISTORY"  # save timestamps and duration in history file
      "GLOB_DOTS"  # make `echo ~/*` include "hidden" .-prefixed entries
      "GLOB_STAR_SHORT"  # allow `**` as shorthand for `**/*` (i.e. recursive glob)
      "HIST_EXPIRE_DUPS_FIRST"  # when history file needs to be trimmed, remove oldest _non-unique_ entry instead of just the oldest entry.
      "HIST_FCNTL_LOCK"  # (nixos default) more reliable locking/concurrency over history file
      "HIST_FIND_NO_DUPS"  # when searching history, skip over entries which have already been shown
      "HIST_IGNORE_DUPS"  # (nixos default) when a command is invoked twice in a row, only add it to history file once
      "INTERACTIVE_COMMENTS"  # allow comments even in interactive shells
      "NO_BEEP"  # don't beep on invalid line-editor operations (e.g. bad completions)
      "NO_CORRECT"  # don't try to correct commands
      # "NULL_GLOB"  # make globs which yield 0 results not be an error
      "PIPE_FAIL"  # when `cmd_a | cmd_b`, make $? be non-zero if *any* of cmd_a or cmd_b fail
      "PUSHD_SILENT"  # `pushd`: don't print directory stack
      "RM_STAR_SILENT"  # disable `rm *` confirmations
      "SHARE_HISTORY"  # share history across all zsh instances
    ];

    # .zshenv config:
    shellInit = ''
      ZDOTDIR=$HOME/.config/zsh
    '';

    # system-wide .zshrc config:
    interactiveShellInit = ''
      # zmv is a way to do rich moves/renames, with pattern matching/substitution.
      # see for an example: <https://filipe.kiss.ink/zmv-zsh-rename/>
      autoload -Uz zmv

      HISTORY_IGNORE='(sane-shutdown *|sane-reboot *|rm *|nixos-rebuild.* switch|switch)'

      ### aliases
      # aliases can be defined in any order, regardless of how they reference eachother.
      # but they must be defined before any functions which use them.
      #
      # ls helpers (eza is a nicer `ls`)
      # l: list directory, one entry per line
      if command -v eza >/dev/null; then
        # --hyperlink makes things clickable on wezterm
        # see: <https://wezterm.org/recipes/hyperlinks.html#requirements>
        alias ls="eza --time-style=long-iso --bytes --hyperlink auto"
      fi

      # these should be compatible with `ls=eza` and plain `ls` (for minimal environments).
      # flag support:
      # - -a|--all: eza, ls
      # - -l: eza, ls
      # - --long: eza ONLY
      # - --sort time: eza, ls
      # - -rt: ls ONLY
      alias l="ls"
      alias la="ls -a"
      alias lal="ls -al"
      alias ll="ls -l"
      alias lla="ls -al"
      alias lrt="ls -l --sort time"

      # escape to use the original (coreutils) `ls`
      alias _ls="env ls"

      ### functions
      # N.B. functions must be defined _after_ any aliases they reference;
      # alias expansion appears to happen at definition time, not call time.
      function c() {
        # list a dir after entering it
        cd "$@"
        ll
      }
      function ct() {
        # list a dir after entering it, based on time
        cd "$@"
        lrt
      }
      function deref() {
        # convert a symlink into a plain file of the same content
        if [ -L "$1" ] && [ -f "$1" ]; then
          cp --dereference "$1" "$1.deref"
          mv -f "$1.deref" "$1"
        fi
        chmod u+w "$1"
      }

      # edit a file, creating leading directories if necessary.
      function edit() {
        local file=$1
        local dir=$(dirname $file)
        [[ -n "$dir" ]] && mkdir -p "$dir"
        [[ -n "$file" ]] && "''${EDITOR:-vim}" "$file"
      };

      function nd() {
        # enter a directory, creating it if necessary
        mkdir -p "$1"
        pushd "$1"
      }

      function repo() {
        # navigate to a local checkout of the source code for repo (i.e. package) $1
        eval $(sane-clone "$1")
      };

      function switch() {
        local dir="$PWD"
        while [[ "$dir" != $(dirname "$dir") ]] && ! [[ -x "$dir/scripts/deploy" ]]; do
          dir=$(dirname "$dir")
        done
        if ! [[ -x "$dir/scripts/deploy" ]]; then
          dir=~/nixos/master
        fi

        ( cd "$dir" && ./scripts/deploy "$@" )
      }

      function tmp() {
        local today=$(date '+%Y-%m-%d')
        if [[ -d ~/tmp/$today ]]; then
          c ~/tmp/$today
        else
          # TODO: if yesterday's directory exists, and the last-modified-time is within 6hrs of now,
          #       we can assume it's the same "day" and cd into the existing directory.
          ct ~/tmp
        fi
      }

      # HACK to support `git work NEW_DIR`: in order for this to `cd` into NEW_DIR, it has to run
      # as a shell function -- not a subprocess.
      function git() {
        if [[ "$1" == "work" ]]; then
          local name="$2"
          command git worktree add "$name" && cd "$name"
        else
          command git "$@"
        fi
      }
    '';

    syntaxHighlighting.enable = true;
    vteIntegration = cfg.config.guiIntegrations;
  };

  # enable a command-not-found hook to show nix packages that might provide the binary typed.
  # programs.nix-index.enableZshIntegration = lib.mkIf cfg.enabled true;
  programs.command-not-found.enable = lib.mkIf cfg.enabled false;
}
