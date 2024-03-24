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

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.sane.zsh;
in
{
  imports = [
    ./starship.nix
  ];
  options = {
    # TODO: port to sane.programs options
    sane.zsh = {
      showDeadlines = mkOption {
        type = types.bool;
        default = true;
        description = "show upcoming deadlines (from my PKM) upon shell init";
      };
      starship = mkOption {
        type = types.bool;
        default = true;
        description = "enable starship prompt";
      };
      guiIntegrations = mkOption {
        type = types.bool;
        default = config.sane.programs.guiApps.enabled;
        description = ''
          integrate with things like VTE, so that windowing systems can show the PWD in the title.
          drags in gtk+3.
        '';
      };
    };
  };

  config = mkMerge [
    ({
      sane.programs.zsh = {
        sandbox.enable = false;  # TODO: i could at least sandbox the prompt (starship)!
        persist.byStore.private = [
          # we don't need to full zsh dir -- just the history file --
          # but zsh will sometimes backup the history file and symlinking just the file messes things up
          ".local/share/zsh"
        ];

        fs.".config/zsh/.zshrc".symlink.text = ''
          # zsh/prezto complains if zshrc doesn't exist or is empty;
          # preserve this comment to prevent that from ever happening.
        '' + lib.optionalString cfg.showDeadlines ''
          ${pkgs.sane-scripts.deadlines}/bin/sane-deadlines
        '' + ''

          HISTFILE="$HOME/.local/share/zsh/history"
          HISTSIZE=1000000
          SAVEHIST=1000000

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

          # emulate bash keybindings
          bindkey -e

          # fixup bindings not handled by bash, see: <https://wiki.archlinux.org/title/Zsh#Key_bindings>
          # `bindkey -e` seems to define most of the `key` array. everything in the Arch defaults except for these:
          key[Backspace]="''${terminfo[kbs]}"
          key[Control-Left]="''${terminfo[kLFT5]}"
          key[Control-Right]="''${terminfo[kRIT5]}"
          key[Shift-Tab]="''${terminfo[kcbt]}"
          bindkey -- "''${key[Delete]}"     delete-char
          bindkey -- "''${key[Control-Left]}"  backward-word
          bindkey -- "''${key[Control-Right]}"  forward-word

          # or manually recreate what i care about...
          # key[Left]=''${terminfo[kcub1]}
          # key[Right]=''${terminfo[kcuf1]}
          # bindkey '^R'               history-incremental-search-backward
          # bindkey '^A'               beginning-of-line
          # bindkey '^E'               end-of-line
          # bindkey "^''${key[Left]}"  backward-word
          # bindkey "^''${key[Right]}" forward-word

          # run any additional, sh-generic commands (useful for e.g. launching a login manager on login)
          test -e ~/.profile && source ~/.profile
        '';
      };
    })
    (mkIf config.sane.programs.zsh.enabled {
      # enable zsh completions
      environment.pathsToLink = [ "/share/zsh" ];

      programs.zsh = {
        enable = true;
        shellAliases = {
          ":q" = "exit";
          # common typos
          "cd.." = "cd ..";
          "cd../" = "cd ../";
          "exiy" = "exit";
          # ls helpers (eza is a nicer `ls`
          "l" = "eza --oneline";  # show one entry per line
          "ll" = "eza --long --time-style=long-iso";
          # overcome poor defaults
          "lsof" = "lsof -P";  #< lsof: use port *numbers*, not names
          "tcpdump" = "tcpdump -n";  #< tcpdump: use port *numbers*, not names
        };
        setOptions = [
          # docs: `man zshoptions`
          # nixos defaults:
          "HIST_FCNTL_LOCK"
          "HIST_IGNORE_DUPS"
          "HIST_EXPIRE_DUPS_FIRST"
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
        interactiveShellInit = ''
          # zmv is a way to do rich moves/renames, with pattern matching/substitution.
          # see for an example: <https://filipe.kiss.ink/zmv-zsh-rename/>
          autoload -Uz zmv

          HISTORY_IGNORE='(sane-shutdown *|sane-reboot *|rm *|nixos-rebuild.* switch|switch)'

          # extra aliases
          # TODO: move to `shellAliases` config?
          function c() {
            # list a dir after entering it
            cd "$1"
            eza --oneline
          }
          function deref() {
            # convert a symlink into a plain file of the same content
            if [ -L "$1" ] && [ -f "$1" ]; then
              cp --dereference "$1" "$1.deref"
              mv -f "$1.deref" "$1"
            fi
            chmod u+w "$1"
          }
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
            nix run '.#deploy.self'
          }
        '';

        syntaxHighlighting.enable = true;
        vteIntegration = cfg.guiIntegrations;
      };

      # enable a command-not-found hook to show nix packages that might provide the binary typed.
      # programs.nix-index.enableZshIntegration = true;
      programs.command-not-found.enable = false;
    })
  ];
}
