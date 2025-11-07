{ config, pkgs, lib, ... }:
let
  cfg = config.my.home.zsh;
in
{
  options.my.home.zsh = with lib; {
    enable = my.mkDisableOption "zsh configuration";

    launchTmux = mkEnableOption "auto launch tmux at shell start";

    completionSync = {
      enable = mkEnableOption "zsh-completion-sync plugin";
    };

    notify = {
      enable = mkEnableOption "zsh-done notification";

      exclude = mkOption {
        type = with types; listOf str;
        default = [
          "bat"
          "delta"
          "direnv reload"
          "fg"
          "git (?!push|pull|fetch)"
          "home-manager (?!switch|build)"
          "htop"
          "less"
          "man"
          "nvim"
          "tail -f"
          "tmux"
          "vim"
        ];
        example = [ "command --long-running-option" ];
        description = ''
          List of exclusions which should not be create a notification. Accepts
          Perl regexes (implicitly anchored with `^\s*`).
        '';
      };

      ssh = {
        enable = mkEnableOption "notify through SSH/non-graphical connections";

        useOsc777 = lib.my.mkDisableOption "use OSC-777 for notifications";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = with pkgs; [
        zsh-completions
      ];

      programs.zsh = {
        enable = true;
        dotDir = "${config.xdg.configHome}/zsh"; # Don't clutter $HOME
        enableCompletion = true;

        history = {
          size = 500000;
          save = 500000;
          extended = true;
          expireDuplicatesFirst = true;
          ignoreSpace = true;
          ignoreDups = true;
          share = false;
          path = "${config.xdg.stateHome}/zsh/zsh_history";
        };

        plugins = [
          {
            name = "fast-syntax-highlighting";
            file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
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

        initContent = lib.mkMerge [
          # Make those happen early to avoid doing double the work
          (lib.mkBefore (lib.optionalString cfg.launchTmux ''
            # Launch tmux unless already inside one
            if [ -z "$TMUX" ]; then
              exec tmux new-session
            fi
          ''))

          (lib.mkAfter ''
            source ${./completion-styles.zsh}
            source ${./extra-mappings.zsh}
            source ${./options.zsh}

            # Source local configuration
            if [ -f "$ZDOTDIR/zshrc.local" ]; then
              source "$ZDOTDIR/zshrc.local"
            fi
          '')
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

        # Enable VTE integration
        enableVteIntegration = true;
      };
    }

    (lib.mkIf cfg.completionSync.enable {
      programs.zsh = {
        plugins = [
          {
            name = "zsh-completion-sync";
            file = "share/zsh-completion-sync/zsh-completion-sync.plugin.zsh";
            src = pkgs.zsh-completion-sync;
          }
        ];
      };
    })

    (lib.mkIf cfg.notify.enable {
      programs.zsh = {
        plugins = [
          {
            name = "zsh-done";
            file = "share/zsh/site-functions/done.plugin.zsh";
            src = pkgs.ambroisie.zsh-done;
          }
        ];

        # `localVariables` values don't get merged correctly due to their type,
        # don't use `mkIf`
        localVariables = {
          DONE_EXCLUDE =
            let
              joined = lib.concatMapStringsSep "|" (c: "(${c})") cfg.notify.exclude;
            in
            ''^\s*(${joined})'';
        }
        # Enable `zsh-done` through SSH, if configured
        // lib.optionalAttrs cfg.notify.ssh.enable {
          DONE_ALLOW_NONGRAPHICAL = 1;
        };

        # Use OSC-777 to send the notification through SSH
        initContent = lib.mkIf cfg.notify.ssh.useOsc777 ''
          done_send_notification() {
            local exit_status="$1"
            local title="$2"
            local message="$3"

            ${lib.getExe pkgs.ambroisie.osc777} "$title" "$message"
          }
        '';
      };
    })
  ]);
}
