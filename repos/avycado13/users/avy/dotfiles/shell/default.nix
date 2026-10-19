{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  colBin = if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/col" else "${pkgs.util-linux}/bin/col";
  # Pre-generated shell init scripts to avoid eval "$(cmd)" subprocess overhead at startup.
  zoxide-init = pkgs.runCommand "zoxide-init.zsh" { } ''
    ${lib.getExe pkgs.zoxide} init zsh > $out
  '';
  direnv-hook = pkgs.runCommand "direnv-hook.zsh" { } ''
    ${lib.getExe pkgs.direnv} hook zsh > $out
  '';
  fzf-init = pkgs.runCommand "fzf-init.zsh" { } ''
    ${lib.getExe pkgs.fzf} --zsh > $out
  '';
  nix-index-init = pkgs.runCommand "nix-index-init.zsh" { } ''
    cp ${pkgs.nix-index}/etc/profile.d/command-not-found.sh $out
  '';
  # atuin init is handled by programs.atuin.enableZshIntegration # NOT ANYMORE
  atuin-init = pkgs.runCommand "atuin-init.zsh" { } ''
    export HOME=$TMPDIR
    ${lib.getExe pkgs.atuin} init zsh > $out
  '';
  zsh-you-should-use-init = pkgs.runCommand "zsh-you-should-use-init.zsh" { } ''
    cp ${pkgs.zsh-you-should-use.src}/zsh-you-should-use.plugin.zsh $out
  '';
  fzf-zsh-plugin-init = pkgs.runCommand "fzf-zsh-plugin-init.zsh" { } ''
    cp ${pkgs.fzf-zsh-plugin.src}/fzf-zsh-plugin.plugin.zsh $out
  '';
  terminal-wakatime-init = pkgs.runCommand "terminal-wakatime-init.zsh" { } ''
    ${
      lib.getExe' inputs.terminal-wakatime.packages.${pkgs.stdenv.hostPlatform.system}.default
        "terminal-wakatime"
    } init zsh > $out
  '';
  navi-init = pkgs.runCommand "navi-init.zsh" { } ''
    ${lib.getExe pkgs.navi} widget zsh > $out
  '';
  zsh-completions-init = pkgs.runCommand "zsh-completions-init.zsh" { } ''
    cp ${pkgs.zsh-completions.src}/zsh-completions.plugin.zsh $out
  '';
  zsh-autosuggestions-init = pkgs.runCommand "zsh-autosuggestions-init.zsh" { } ''
    cp ${pkgs.zsh-autosuggestions.src}/zsh-autosuggestions.zsh $out
  '';

  # Everything sourced into interactive zsh, in order. Each entry is a store
  # path holding ready-to-source zsh; nothing is eval'd at startup.
  shell-init = [
    zoxide-init
    fzf-init
    direnv-hook
    atuin-init
  ];
  defer-init = [
    nix-index-init
    zsh-you-should-use-init
    fzf-zsh-plugin-init
    terminal-wakatime-init
    navi-init
    zsh-completions-init
    zsh-autosuggestions-init
    # forgit-init
  ];
  patinaConfig = (pkgs.formats.toml { }).generate "zsh-patina-config.toml" {
    highlighting = {
      theme = "catppuccin-mocha";
    };
  };
in
{
  options.dots.shell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the shell dotfiles module.";
    };

    profiling.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Profile zsh startup with zprof. Prints a breakdown of time spent in
        each sourced function/plugin at the end of every interactive shell
        startup. Meant to be toggled on temporarily to diagnose slow
        startups, not left enabled.
      '';
    };
  };

  config = lib.mkIf config.dots.shell.enable {

    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/go/bin"
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      "$HOME/finance/bin"
      "$HOME/.cargo/bin"
      "$HOME/.bun/bin"
      "$HOME/.nix-profile/bin"
      "/run/wrappers/bin"
      "/etc/profiles/per-user/$USER/bin"
      "/nix/var/nix/profiles/default/bin"
      "/run/current-system/sw/bin"
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      "/opt/local/bin"
      "/opt/local/sbin"
      "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
      "$HOME/Library/pnpm"
      "$HOME/Library/Android/sdk/platform-tools"
    ];

    home.sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      # Colourful man pages: -c stops groff emitting its own escapes, col
      # strips the overstrike it uses for bold and underline, and bat
      # highlights what is left with the usual theme.
      MANROFFOPT = "-c";
      MANPAGER = "sh -c '${colBin} -bx | ${pkgs.bat}/bin/bat -l man -p --theme=ansi'";
      NIKS3_AUTH_TOKEN_FILE = config.sops.secrets.niks3_api_token.path;
      NIKS3_SERVER_URL = "https://cache.avyay.in";
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES";
      # Use Apple's toolchain for native builds. nix's cc/clang don't wire in
      # the macOS SDK, so cgo/cargo/cmake links fail with "library not found"
      # (e.g. -lresolv). Apple's cc handles SDK, frameworks, and code signing
      # natively. Respected by cgo ($CC), cargo, cmake, etc.
      CC = "/usr/bin/cc";
      CXX = "/usr/bin/c++";
      DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/default/docker.sock";
    };

    home.activation.mkPnpmHome = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${config.home.homeDirectory}/Library/pnpm"
      ''
    );

    home.packages = [
      pkgs.zsh-patina
      pkgs.zsh-forgit
    ];
    xdg.configFile."zsh-patina/config.toml".source = patinaConfig;
    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;

        completionInit = ''
          () {
            emulate -L zsh
            [[ -o interactive ]] || return
            autoload -Uz compinit complist
            # Use fpath directory count as cache key (sub-ms vs 89ms for full file glob).
            local zcd="''${ZDOTDIR:-$HOME}/.zcompdump-''${ZSH_VERSION}-''${#fpath}"
            local zcdc=$zcd.zwc
            local zcda=$zcd.last
            if [[ -e $zcda && -n $zcda(#qN.mh+24) ]]; then
              # Stale: rebuild in background, use cached dump this session.
              { compinit -u -d $zcd; : > $zcda; rm -f $zcdc && zcompile $zcd } &!
              compinit -C -d $zcd
            elif [[ -f $zcd ]]; then
              compinit -C -d $zcd
            else
              # First run or missing dump: full init
              compinit -u -d $zcd
              : > $zcda
              [[ ! -f $zcdc || $zcd -nt $zcdc ]] && rm -f $zcdc && zcompile $zcd &!
            fi
          }
        '';

        plugins = [
          {
            name = pkgs.zsh-fzf-tab.pname;
            src = pkgs.zsh-fzf-tab.src;
            file = "fzf-tab.plugin.zsh";
          }
          {
            name = pkgs.zsh-defer.pname;
            src = pkgs.zsh-defer.src;
            file = "zsh-defer.plugin.zsh";
          }
          # {
          #   name = pkgs.zsh-forgit.pname;
          #   src = pkgs.zsh-forgit.src;
          #   file = "forgit.plugin.zsh";
          # }
        ];

        shellAliases = {
          ash = "${lib.getExe pkgs.autossh} -M 0 -q";
          aspm = "sudo lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'";
          b = "${lib.getExe pkgs.buku} --suggest";
          cat = "${lib.getExe pkgs.bat}";
          cfip = ''dig @1.1.1.1 ch txt whoami.cloudflare +short | tr -d '"' '';
          cp = "cp -iv";
          df = "df -h";
          du = "du -ch";

          fzkill = ''
            (date; ps -ef) |
              ${lib.getExe pkgs.fzf} --bind='ctrl-r:reload(date; ps -ef)' \
                --header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
                --preview='echo {}' --preview-window=down,3,wrap \
                --layout=reverse --height=80% |
              awk '{print $2}' | xargs kill -9
          '';

          fzmanix = "'${lib.getExe pkgs.manix}' | rg '^# ' | sed 's/^# \\(.*\\) (.*/\\1/;s/ (.*//;s/^# //' | fzf --preview=\"${lib.getExe pkgs.manix} '{}'\" | xargs manix";
          ghrpc = "${lib.getExe pkgs.gh} repo create -c";
          ghrpv = "${lib.getExe pkgs.gh} repo view --web";
          goops = "${lib.getExe pkgs.git} commit --amend --no-edit && ${lib.getExe pkgs.git} push --force-with-lease";
          ipp = "${lib.getExe pkgs.curl} ipinfo.io/ip";
          jsenv = "${lib.getExe pkgs.ripgrep} -o --no-filename 'process\\.env\\.[A-Z0-9_]+' | sort -u | awk -F. '{print $3\"=\\\"\\\"\"}'";
          ls = "${lib.getExe pkgs.eza}";
          mkdir = "mkdir -p";
          md = "mkdir";
          mv = "mv -iv";
          ols = "ls -la --color=never | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'";
          rm = "rm -iv";
          rr = "rm -Rf";
          pyserver = "${lib.getExe pkgs.python3} -m http.server";
          uva = "${lib.getExe pkgs.uv} add";
          uvexp = "${lib.getExe pkgs.uv} export --format requirements-txt --no-hashes --output-file requirements.txt --quiet";
          uvl = "${lib.getExe pkgs.uv} lock";
          uvp = "${lib.getExe pkgs.uv} pip";
          uvr = "${lib.getExe pkgs.uv} run";
          uvrm = "${lib.getExe pkgs.uv} remove";
          uvs = "${lib.getExe pkgs.uv} sync";
          uvv = "${lib.getExe pkgs.uv} venv";
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          flush-dns = "sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder";
          lsblk = "diskutil list";
        };

        initContent = ''
           ${lib.optionalString config.dots.shell.profiling.enable ''
             zmodload zsh/zprof
           ''}

           ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
             builtin ulimit -n 2048
           ''}

           # if (( $+commands[motd] )); then
             # motd
           # fi

           # Keep the shell in the filesystem's canonical path. gopls rejects
           # differently cased macOS paths (e.g. ~/code instead of ~/Code).
           canonicalize_pwd() {
             local canonical
             canonical="$(${lib.getExe' pkgs.coreutils "realpath"} .)" || return
             [[ "$PWD" == "$canonical" ]] || builtin cd -- "$canonical"
           }
           autoload -Uz add-zsh-hook
           add-zsh-hook chpwd canonicalize_pwd
           canonicalize_pwd

           # --- Keybindings & widgets ---
           bindkey -e

           fancy-ctrl-z() {
             if [[ -z $BUFFER ]]; then
               BUFFER="fg"
               zle accept-line
             else
               zle push-input
               zle clear-screen
             fi
           }
           zle -N fancy-ctrl-z
           bindkey '^Z' fancy-ctrl-z

           bindkey '^B' autosuggest-toggle

           # Make Ctrl+W remove one path segment instead of the whole path
           WORDCHARS=''${WORDCHARS/\/}

           # Highlight the selected suggestion
           zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
           zstyle ':completion:*' menu no
           zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
           zstyle ':fzf-tab:complete:__zoxide_cd:*' fzf-preview 'ls --color $realpath'

           ${lib.concatMapStringsSep "\n" (f: "source ${f}") shell-init}\

           bindkey ' ' magic-space

           alias -g NE='2>/dev/null'
           alias -g NO='>/dev/null'
           alias -g NUL='>/dev/null 2>&1'
           alias -g J='| jq'
           
           # OSC 52 clipboard (works over SSH)
           function osc52copy() {
             local data=$(cat "$@" | base64 | tr -d '\n')
             printf "\033]52;c;%s\a" "$data"
           }
           alias -g C='| osc52copy'
           # Clear screen but keep current command buffer (Ctrl+X, Ctrl+L)
           function clear-screen-and-scrollback() {
             echoti civis >"$TTY"
             printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
             echoti cnorm >"$TTY"
             zle redisplay
           }
           zle -N clear-screen-and-scrollback
           bindkey '^X^L' clear-screen-and-scrollback

           # Copy current command buffer to clipboard (Ctrl+X, Ctrl+C) - OSC 52 for SSH support
           function copy-buffer-to-clipboard() {
             local data=$(echo -n "$BUFFER" | base64 | tr -d '\n')
             printf "\033]52;c;%s\a" "$data"
             zle -M "Copied to clipboard"
           }
           zle -N copy-buffer-to-clipboard
           bindkey '^X^C' copy-buffer-to-clipboard
           # Edit command buffer in $EDITOR (Ctrl+X, Ctrl+E)
           autoload -Uz edit-command-line
           zle -N edit-command-line
           bindkey '^X^E' edit-command-line

           # --- Deferred integrations (pushed off the critical path so the
           # first prompt renders immediately; these finish loading right
           # after it appears) ---
           ${lib.concatMapStringsSep "\n" (f: "zsh-defer source ${f}") defer-init}\

           # zsh-patina's activate output embeds $TMPDIR (for its daemon
           # socket path), so it must be eval'd at runtime rather than
           # pre-baked into a store path at build time.
           zsh-defer ${lib.getExe pkgs.zsh-patina} start
           zsh-defer eval 'eval "$(${lib.getExe pkgs.zsh-patina} activate)"'



          # Double-tap escape to prepend sudo (from oh-my-zsh sudo plugin)
          __sudo-replace-buffer() {
            local old=$1 new=$2 space=''${2:+ }
            if [[ $CURSOR -le ''${#old} ]]; then
              BUFFER="''${new}''${space}''${BUFFER#$old }"
              CURSOR=''${#new}
            else
              LBUFFER="''${new}''${space}''${LBUFFER#$old }"
            fi
          }
          sudo-command-line() {
            [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
            local WHITESPACE=""
            if [[ ''${LBUFFER:0:1} = " " ]]; then
              WHITESPACE=" "
              LBUFFER="''${LBUFFER:1}"
            fi
            {
              local EDITOR=''${SUDO_EDITOR:-''${VISUAL:-$EDITOR}}
              if [[ -z "$EDITOR" ]]; then
                case "$BUFFER" in
                  sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
                  sudo\ *) __sudo-replace-buffer "sudo" "" ;;
                  *) LBUFFER="sudo $LBUFFER" ;;
                esac
                return
              fi
              local cmd="''${''${(Az)BUFFER}[1]}"
              local realcmd="''${''${(Az)aliases[$cmd]}[1]:-$cmd}"
              local editorcmd="''${''${(Az)EDITOR}[1]}"
              if [[ "$realcmd" = (\$EDITOR|$editorcmd|''${editorcmd:c}) \
                || "''${realcmd:c}" = ($editorcmd|''${editorcmd:c}) ]] \
                || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
                __sudo-replace-buffer "$cmd" "sudo -e"
                return
              fi
              case "$BUFFER" in
                $editorcmd\ *) __sudo-replace-buffer "$editorcmd" "sudo -e" ;;
                \$EDITOR\ *) __sudo-replace-buffer '$EDITOR' "sudo -e" ;;
                sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
                sudo\ *) __sudo-replace-buffer "sudo" "" ;;
                *) LBUFFER="sudo $LBUFFER" ;;
              esac
            } always {
              LBUFFER="''${WHITESPACE}''${LBUFFER}"
              zle && zle redisplay
            }
          }
          zle -N sudo-command-line
          bindkey -M emacs '\e\e' sudo-command-line
          bindkey -M vicmd '\e\e' sudo-command-line
          bindkey -M viins '\e\e' sudo-command-line

           # --- Functions ---
           mdc() {
             mkdir -p "$1" && cd "$1"
           }
          ${lib.optionalString config.dots.shell.profiling.enable ''
            zprof
          ''}           
        '';
      };
      atuin = {
        enable = true;
        enableZshIntegration = false; # Look at top; file content generated at build

        settings = {
          auto_sync = true;
          sync_frequency = "5m";
          sync_address = "https://api.atuin.sh";
          search_mode = "fuzzy";
          session_path = config.sops.secrets.atuin-session.path;
          key_path = config.sops.secrets.atuin-key.path;
        };
      };
      bat.enable = true;
      direnv = {
        enable = true;
        enableZshIntegration = false;
        nix-direnv.enable = true;
      };
      eza = {
        enable = true;
        enableZshIntegration = false;
        git = true;
        colors = "auto";
        icons = "auto";
      };
      fd.enable = true;
      fzf = {
        enable = true;
        enableZshIntegration = false;

        historyWidget.command = "";
      };
      navi = {
        enable = true;

        # Loaded via zsh-defer in initContent instead (only binds a widget, so it
        # doesn't need to block the first prompt).
        enableZshIntegration = false;

        settings.cheats.paths = [
          "~/cheats/"
        ];
      };
      nix-index = {
        enable = true;
        enableZshIntegration = false;
      };
      nix-index-database.comma.enable = true;
      nix-search-tv = {
        enable = true;

        settings = {
          indexes = [
            "nixpkgs"
            "nixos"
            "home-manager"
            "nur"
            "noogle"
            "darwin"
          ];

          experimental.options_file = {
            # sops-nix-home = mkOpts pkgs.stdenv.hostPlatform.system inputs.sops-nix.homeModules.default;
            # sops-nix-darwin = mkOpts pkgs.stdenv.hostPlatform.system inputs.sops-nix.darwinModules.default;
            # sops-nix-nixos = mkOpts pkgs.stdenv.hostPlatform.system inputs.sops-nix.nixosModules.default;
            # catppuccin-home = mkOpts pkgs.stdenv.hostPlatform.system inputs.catppuccin.homeModules.default;
            # catppuccin-nixos = mkOpts pkgs.stdenv.hostPlatform.system inputs.catppuccin.nixosModules.default;
          };

          render_docs_indexes.home-manager = "https://nix-community.github.io/home-manager/options.xhtml";
        };
      };
      pandoc.enable = true;

      rclone.enable = true;

      ripgrep.enable = true;

      starship = {
        enable = true;

        settings = {
          add_newline = false;

          # format = ''
          #   ''${env_var.ZMX_SESSION}\
          #   $directory\
          #   $git_branch\
          #   $git_status\
          #   $character
          # '';

          # env_var.ZMX_SESSION = {
          #   symbol = " ";
          #   format = "[$symbol$env_value]($style) ";
          #   description = "zmx session name";
          #   style = "bold magenta";
          # };

          aws.disabled = true;

          gcloud.detect_env_vars = [
            "GOOGLE_CLOUD"
          ];
        };
      };
      yazi = {
        enable = true;
        enableZshIntegration = false;
        shellWrapperName = "yy";
        plugins = with pkgs.yaziPlugins; {
          # Plugins that don't call setup() can be configured in one line
          smart-enter.package = smart-enter;
          chmod.package = chmod;
          diff.package = diff;
        };
        initLua = ''
          Header:children_add(function()
            if ya.target_family() ~= "unix" then
            		return ""
            end
            return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
          end, 500, Header.LEFT)
        '';

        settings = {
          mgr = {
            prepend_keymap = [
              {
                on = "<C-p>";
                run = "shell -- qlmanage -p %s";
              }
              {
                on = "<C-alt-d>";
                run = "plugin diff";
                desc = "Diff the selected with the hovered file";
              }
            ];
          };
        };
      };

      zoxide = {
        enable = true;
        enableZshIntegration = false;
        options = [ "--cmd cd" ];
      };
    };
  };
}
