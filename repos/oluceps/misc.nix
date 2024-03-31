# original configuration.nix w
{ inputs
, config
, pkgs
, lib
, user
, ...
}:
{
  nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${user}/Src/nixos";
  };
  systemd.services.nix-daemon = {
    serviceConfig.LimitNOFILE = lib.mkForce 500000000;
  };

  virtualisation = {
    vmVariant = {
      virtualisation = {
        memorySize = 2048;
        cores = 6;
      };
    };
    docker.enable = false;
    podman = {
      enable = true;
      dockerSocket.enable = true;
      dockerCompat = true;
    };
  };
  nix = {
    package = pkgs.nixVersions.stable;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      self.flake = inputs.self;
    };

    settings = {
      nix-path = [
        "nixpkgs=${pkgs.path}"
      ];
      keep-outputs = true;
      keep-derivations = true;
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.ngi0.nixos.org-1:KqH5CBLNSyX184S9BKZJo1LxrxJ9ltnY2uAs5c/f1MA="
        "nur-pkgs.cachix.org-1:PAvPHVwmEBklQPwyNZfy4VQqQjzVIaFOkYYnmnKco78="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
        "dev:q113qnHgjtHEiiaU/eFcT0mIQZg9cbu9nPYja6ojhqI="
      ];
      substituters = (map (n: "https://${n}.cachix.org")
        [ "nix-community" "nur-pkgs" "hyprland" "helix" "nixpkgs-wayland" "anyrun" "ezkea" "devenv" "colmena" ])
      ++
      [
        "https://cache.nixos.org"
        "https://cache.ngi0.nixos.org"
        "https://attic.nyaw.xyz/dev"
        # "https://mirror.sjtu.edu.cn/nix-channels/store"
      ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
        "cgroups"
        "repl-flake"
        "recursive-nix"
        "ca-derivations"
      ];
      auto-allocate-uids = true;
      use-cgroups = true;

      trusted-users = [ "root" "${user}" ];
      # Avoid disk full
      max-free = lib.mkDefault (1000 * 1000 * 1000);
      min-free = lib.mkDefault (128 * 1000 * 1000);
      builders-use-substitutes = true;
    };

    daemonCPUSchedPolicy = lib.mkDefault "batch";
    daemonIOSchedClass = lib.mkDefault "idle";
    daemonIOSchedPriority = lib.mkDefault 7;


    extraOptions = ''
      !include ${config.age.secrets.gh-token.path}
    '';
  };

  time.timeZone = "Asia/Singapore";

  console = {
    # font = "LatArCyrHeb-16";
    keyMap = "us";
  };
  security = {
    pki.certificateFiles = [ "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
    pam = {
      u2f = {
        enable = true;
        authFile = config.age.secrets."${user}.u2f".path;
        control = "sufficient";
        cue = true;
      };
      loginLimits = [
        {
          domain = "*";
          type = "-";
          item = "memlock";
          value = "unlimited";
        }
      ];
      services = {
        sudo.u2fAuth = true;
      };
    };
    polkit.enable = true;
  };

  services = {

    bpftune.enable = true;

    journald.extraConfig =
      ''
        SystemMaxUse=1G
      '';

    dbus = {
      enable = true;
      implementation = "broker";
    };

  };

  documentation = {
    enable = true;
    nixos.enable = false;
    man.enable = false;
  };

  systemd.tmpfiles.rules = [
    "C /var/cache/tuigreet/lastuser - - - - ${pkgs.writeText "lastuser" "${user}"}"
  ];

  i18n.defaultLocale = "en_GB.UTF-8";

  environment.etc = {
    "machine-id".text = "b08dfa6083e7567a1921a715000001fb\n";
  };
  programs = {

    git.enable = true;
    bash = {
      interactiveShellInit = ''
        eval "$(${pkgs.zoxide}/bin/zoxide init bash)"
        eval "$(${lib.getExe pkgs.atuin} init bash)"
      '';
      blesh.enable = true;
    };
    nix-ld.enable = true;
    fish = {
      enable = true;
      shellAliases = {
        j = "just";
        nd = "cd /home/${user}/Src/nixos";
        swc = "sudo nixos-rebuild switch --flake /home/${user}/Src/nixos";
        #--log-format internal-json -v 2>&1 | nom --json";
        daso = "sudo";
        daos = "sudo";
        off = "poweroff";
        mg = "kitty +kitten hyperlinked_grep --smart-case $argv .";
        kls = "lsd --icon never --hyperlink auto";
        lks = "lsd --icon never --hyperlink auto";
        sl = "lsd --icon never --hyperlink auto";
        ls = "lsd --icon never --hyperlink auto";
        l = "lsd --icon never --hyperlink auto -lh";
        la = "lsd --icon never --hyperlink auto -la";
        g = "lazygit";
        "cd.." = "cd ..";
        up = "nix flake update --commit-lock-file /etc/nixos && swc";
        fp = "fish --private";
        e = "exit";
        rp = "rustplayer";
        y = "yazi";
        i = "kitty +kitten icat";
        ".." = "cd ..";
        "。。" = "cd ..";
        "..." = "cd ../..";
        "。。。" = "cd ../..";
        "...." = "cd ../../..";
        "。。。。" = "cd ../../..";
      } // lib.genAttrs [ "rha" "lsa" "tcs" "ubt" "rka" "dgs" "rt" ] (n: "ssh ${n} -t fish");


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

        ${pkgs.atuin}/bin/atuin init fish | source
      '';
    };

    starship = {
      enable = true;
      settings = (import ./home/programs/starship { }).programs.starship.settings // {
        format = "$username$hostname$directory$git_branch$git_commit$git_status$nix_shell$cmd_duration$line_break$python$character";
      };
    };
  };

}
