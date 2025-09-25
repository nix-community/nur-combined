# original configuration.nix w
{
  inputs,
  config,
  pkgs,
  lib,
  user,
  ...
}:
{
  system = {

    # systemd.sysusers.enable = true;
    # apply.enable = true;
    copySystemConfiguration = false;

    disableInstallerTools = true;
    tools.nixos-rebuild.enable = false;
  };
  systemd.services = {
    systemd-networkd.serviceConfig.TimeoutStopSec = "10s";
    nix-daemon.serviceConfig = {
      MemoryAccounting = true;
      MemoryMax = "90%";
      OOMScoreAdjust = 500;
    };

    nix-daemon.serviceConfig = {
      # WARNING: THIS makes nix-daemon build extremely slow
      # LimitNOFILE = lib.mkForce 500000000;
      Environment = [ "TMPDIR=/var/tmp/nix-daemon" ];
    };
  };
  virtualisation.oci-containers.backend = "podman";
  programs = {
    less.lessopen = null;
    command-not-found.enable = false;

    bash = {
      blesh.enable = true;
      interactiveShellInit = ''
        # https://codeberg.org/dnkl/foot/wiki#piping-last-command-s-output
        PS0+='\e]133;C\e\\'

        command_done() {
            printf '\e]133;D\e\\'
        }
        PROMPT_COMMAND=''${PROMPT_COMMAND:+$PROMPT_COMMAND; }command_done
      '';
    };
    fish = {
      enable = true;
      shellAliases = {
        j = "just";
        ls = "eza --icons=auto --hyperlink --color=always --color-scale=all --color-scale-mode=gradient --git --git-repos";
        la = "eza --icons=auto --hyperlink --color=always --color-scale=all --color-scale-mode=gradient --git --git-repos -la";
        l = "eza --icons=auto --hyperlink --color=always --color-scale=all --color-scale-mode=gradient --git --git-repos -lh";
        nd = "cd /home/${user}/Src/nixos";
        bl = "cd /home/${user}/Src/blog.nyaw.xyz";
        swc = "sudo nixos-rebuild switch --flake /home/${user}/Src/nixos";
        #--log-format internal-json -v 2>&1 | nom --json";
        daso = "sudo";
        daos = "sudo";
        off = "poweroff";
        mg = "kitty +kitten hyperlinked_grep --smart-case $argv .";
        kls = "lsd --icon never --hyperlink auto";
        lks = "lsd --icon never --hyperlink auto";
        g = "lazygit";
        "cd.." = "cd ..";
        up = "nix flake update --commit-lock-file /etc/nixos && swc";
        fp = "fish --private";
        e = "exit";
        rp = "rustplayer";
        y = "yazi";
        i = "kitty +kitten icat";
        sc = "systemctl";
        scs = "systemctl status";
        scr = "systemctl restart";
        ".." = "cd ..";
        "。。" = "cd ..";
        "..." = "cd ../..";
        "。。。" = "cd ../..";
        "...." = "cd ../../..";
        "。。。。" = "cd ../../..";
      }
      // lib.genAttrs [
        "rha"
        "lsa"
        "tcs"
        "ubt"
        "rka"
        "dgs"
        "rt"
      ] (n: "ssh ${n} -t fish");

      shellInit = ''
        fish_vi_key_bindings
        set -g direnv_fish_mode eval_on_arrow
        set -U fish_greeting
        set fish_color_normal normal
        set fish_color_command blue
        set fish_color_quote yellow
        set fish_color_redirection cyan --bold
        set fish_color_end green
        set fish_color_error brred
        set fish_color_param cyan
        set fish_color_comment red
        set fish_color_match --background=brblue
        set fish_color_selection white --bold --background=brblack
        set fish_color_search_match bryellow --background=brblack
        set fish_color_history_current --bold
        set fish_color_operator brcyan
        set fish_color_escape brcyan
        set fish_color_cwd green
        set fish_color_cwd_root red
        set fish_color_valid_path --underline
        set fish_color_autosuggestion white
        set fish_color_user brgreen
        set fish_color_host normal
        set fish_color_cancel --reverse
        set fish_pager_color_prefix normal --bold --underline
        set fish_pager_color_progress brwhite --background=cyan
        set fish_pager_color_completion normal
        set fish_pager_color_description B3A06D --italics
        set fish_pager_color_selected_background --reverse
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink


        # if test -z "$SSH_AUTH_SOCK" -a -n "$XDG_RUNTIME_DIR"
        #   set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
        # end
      '';
      interactiveShellInit = ''
        # Need to declare here, since something buggy.
        # For foot `jump between prompt` function
        function mark_prompt_start --on-event fish_prompt
            echo -en "\e]133;A\e\\"
        end

        function fish_user_key_bindings
            for mode in insert default visual
              bind -M $mode \cf forward-char
            end
        end
      '';
    };

    starship = {
      enable = true;
      settings = {
        add_newline = false;

        scan_timeout = 10;

        command_timeout = 1000;

        format = "$username$hostname$directory$git_branch$git_commit$git_status$nix_shell$cmd_duration$line_break$python$character";

        directory.style = "blue";

        character = {
          success_symbol = "[>](white)";
          error_symbol = "[>](red)";
          vicmd_symbol = "[<](green)";
          vimcmd_replace_one_symbol = "[<](bold purple)";
          vimcmd_replace_symbol = "[<](bold purple)";
          vimcmd_visual_symbol = "[<](bold yellow)";
        };

        hostname = {
          ssh_only = false;
          format = "[$hostname]($style) ";
          style = "#91b493";
        };

        git_branch = {
          format = "[$branch]($style) ";
          style = "#F17C67";
        };

        git_commit = {
          format = "[$hash]($style) ";
          style = "#c8adc4";
          only_detached = false;
          tag_disabled = true;
        };

        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style) ";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };

        git_state = {
          format = "\([$state( $progress_current/$progress_total)]($style)\) ";
          style = "bright-black";
        };

        directory = {
          truncation_length = 5;
          format = "[$path]($style) ";
        };

        cmd_duration = {
          format = "[$duration]($style)";
          style = "yellow";
        };
        python = {
          format = "[$virtualenv]($style)";
          style = "bright-black";
        };

        time = {
          disabled = false;
          format = "$time($style) ";
          time_format = "%T";
          style = "bold yellow";
          utc_time_offset = "-5";
        };

        nix_shell = {
          format = "[$symbol$state( \($name\))]($style) ";
        };
      };
    };

  };
  boot.enableContainers = false;
  environment = {
    defaultPackages = [ ];

    # srv.earlyoom.enable = true;
    systemPackages = [
      pkgs.eza
    ];

    etc = {
      "NIXOS".text = "";
      "machine-id".text = "b08dfa6083e7567a1921a715000001fb\n";
      "sbctl/sbctl.conf".source =
        let
          sbctlVar = "/var/lib/sbctl";
        in
        (pkgs.formats.yaml { }).generate "sbctl.conf" {
          bundles_db = "${sbctlVar}/bundles.json";
          db_additions = [ "microsoft" ];
          files_db = "${sbctlVar}/files.json";
          guid = "${sbctlVar}/GUID";
          keydir = "${sbctlVar}/keys";
          keys = {
            db = {
              privkey = "${sbctlVar}/keys/db/db.key";
              pubkey = "${sbctlVar}/keys/db/db.pem";
              type = "file";
            };
            kek = {
              privkey = "${sbctlVar}/keys/KEK/KEK.key";
              pubkey = "${sbctlVar}/keys/KEK/KEK.pem";
              type = "file";
            };
            pk = {
              privkey = "${sbctlVar}/keys/PK/PK.key";
              pubkey = "${sbctlVar}/keys/PK/PK.pem";
              type = "file";
            };
          };
          landlock = true;
        };
    };
  };
  documentation = {
    info.enable = false;
    nixos.enable = false;
    man.man-db.enable = true;
  };
  boot.tmp.useTmpfs = true;

  # powerManagement.powertop.enable = true;

  nix = {
    package = pkgs.nixVersions.stable;
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    channel.enable = false;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    settings = {
      flake-registry = "";
      nix-path = [ "nixpkgs=${pkgs.path}" ];
      fsync-store-paths = true;
      keep-outputs = true;
      keep-derivations = true;
      trusted-users = [ "remotebuild" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
        # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
      ];
      extra-substituters = [
        "https://cache.lix.systems"
      ]
      ++ (map (n: "https://${n}.cachix.org") [
        "nix-community"
        "nixpkgs-wayland"
        "microvm"
      ]);
      substituters = [
        # "https://cache.garnix.io"
      ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
        "recursive-nix"
        "ca-derivations"
        # "pipe-operator"
        "pipe-operators"
        "blake3-hashes"
      ];
      auto-allocate-uids = true;
      use-cgroups = true;

      # Avoid disk full
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
      max-jobs = "auto";
      cores = 0;
      builders-use-substitutes = true;
      allow-import-from-derivation = true;
      download-buffer-size = 524288000;
    };

    daemonCPUSchedPolicy = lib.mkDefault "batch";
    daemonIOSchedClass = lib.mkDefault "idle";
    daemonIOSchedPriority = lib.mkDefault 7;

    extraOptions = ''
      !include ${config.vaultix.secrets.gh-token.path}
    '';
  };

  time.timeZone = "Asia/Singapore";

  console = {
    # font = "LatArCyrHeb-16";
    keyMap = "us";
  };
  security = {
    pki = {
      certificateFiles = [
        "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        lib.data.ca_cert.root_file
      ];
      # caCertificateBlacklist = [
      #   "CNNIC ROOT"
      #   "CNNIC SSL"
      #   "China Internet Network Information Center EV Certificates Root"
      #   "WoSign"
      #   "WoSign China"
      #   "CA WoSign ECC Root"
      #   "Certification Authority of WoSign G2"
      # ];
    };

    sudo.extraConfig = ''
      Defaults lecture="never"
    '';
    polkit.enable = true;
  };

  services = {

    # bpftune.enable = true;
    chrony = {
      enable = true;
      extraConfig = ''
        makestep 1.0 3
      '';
    };
    journald.extraConfig = ''
      SystemMaxUse=1G
    '';

    dbus.implementation = "broker";
  };

  systemd.tmpfiles.rules = [
    "C /var/cache/tuigreet/lastuser - - - - ${pkgs.writeText "lastuser" "${user}"}"
    "d /var/tmp/nix-daemon 0755 root root -"
    "d /var/lib/ssh 0755 root root -"
    "L /home/${user}/.nix-profile - - - - /home/${user}/.local/state/nix/profiles/profile"
    "L /home/${user}/.blerc - - - - ${pkgs.writeText "blerc" ''
      bleopt term_true_colors=none
      bleopt prompt_ruler=empty-line
      ble-face -s command_builtin_dot       fg=yellow,bold
      ble-face -s command_builtin           fg=yellow
      ble-face -s filename_directory        underline,fg=magenta
      ble-face -s filename_directory_sticky underline,fg=white,bg=magenta
      ble-face -s command_function          fg=blue

      function ble/prompt/backslash:my/starship-right {
        local right
        ble/util/assign right '${pkgs.starship}/bin/starship prompt --right'
        ble/prompt/process-prompt-string "$right"
      }
      bleopt prompt_rps1="\n\n\q{my/starship-right}"
      bleopt prompt_ps1_final="\033[1m=>\033[0m "
      bleopt prompt_rps1_transient="same-dir"
    ''}"
  ];

  i18n.defaultLocale = "en_GB.UTF-8";
}
