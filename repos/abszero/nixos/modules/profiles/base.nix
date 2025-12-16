{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkDefault
    mkIf
    const
    genAttrs
    ;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.base;
in

{
  imports = [ ../../../lib/modules/config/abszero.nix ];

  options.abszero.profiles.base.enable = mkExternalEnableOption config "base profile";

  config = mkIf cfg.enable {
    abszero.boot.quiet = true;

    nix = {
      package = pkgs.nixVersions.latest;

      channel.enable = false;

      settings = {
        trusted-users = [
          "root"
          "@wheel"
        ];
        substituters = [
          # CN mirrors of https://cache.nixos.org
          # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          # "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://abszero.cachix.org"
          "https://ai.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "abszero.cachix.org-1:HXOydaS51jSWrM07Ko8AVtGdoBRT9F+QhdYQBiNDaM0="
          "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;
      };

      extraOptions = ''
        experimental-features = nix-command flakes auto-allocate-uids no-url-literals
        use-xdg-base-directories = true
        keep-outputs = true
        keep-derivations = true
        connect-timeout = 10
      '';
    };

    nixpkgs.config.allowUnfree = true;

    system = {
      stateVersion = "26.05";
      nixos-init.enable = true; # Initialise system with a Rust program
      etc.overlay.enable = true; # Mount /etc as overlay; required for nixos-init
    };

    # Certain services freeze on stop which prevents shutdown.
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

    # With p-state, powersave balance_performance often outperforms performance performance.
    # Also, the performance governor requires performance EPP, meaning EPP can't be changed.
    powerManagement.cpuFreqGovernor = mkDefault "powersave";

    boot = {
      initrd.systemd.enable = true; # Required for nixos-init
      loader = {
        timeout = 0;
        # Whether the installation process can modify EFI boot variables.
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          configurationLimit = 5;
          # Disable kernel command line editor for security
          editor = false;
        };
      };
      kernel.sysctl."vm.swappiness" = mkDefault 20;
      tmp.useTmpfs = true;
    };

    users = {
      mutableUsers = false;
      users = genAttrs config.abszero.users.admins (const {
        extraGroups = [
          "audio" # For pipeire
          "video" # For brillo
          "networkmanager"
        ];
      });
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "C.UTF-8/UTF-8"
        # "en_CA.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        # "fr_CA.UTF-8/UTF-8"
        # "zh_CN.UTF-8/UTF-8"
        "ja_JP.UTF-8/UTF-8"
      ];
      extraLocaleSettings = {
        # LC_TIME = "en_US.UTF-8";
        LC_NUMERIC = "C.UTF-8";
      };
    };

    console = {
      font = "ter-u22b";
      packages = with pkgs; [ terminus_font ];
    };

    security.sudo-rs = {
      enable = true;
      wheelNeedsPassword = mkDefault false;
      execWheelOnly = true;
    };

    services = {
      dbus.implementation = "broker";
      journald.console = "/dev/tty10";
      userborn.enable = true; # Manage users with userborn; required for nixos-init
    };

    # Allow unfree packages
    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  };
}
