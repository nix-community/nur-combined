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
    getExe
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

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };

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
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "abszero.cachix.org-1:HXOydaS51jSWrM07Ko8AVtGdoBRT9F+QhdYQBiNDaM0="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;
      };

      extraOptions = ''
        experimental-features = nix-command flakes auto-allocate-uids no-url-literals
        keep-outputs = true
        keep-derivations = true
        connect-timeout = 10
      '';
    };

    nixpkgs.config.allowUnfree = true;

    system = {
      stateVersion = "24.11";
      # Print store diff using nvd
      activationScripts.diff = {
        supportsDryActivation = true;
        text = ''
          if [ -d /run/current-system ]; then
            ${getExe pkgs.nvd} --nix-bin-dir=${config.nix.package}/bin diff \
              /run/current-system "$systemConfig"
          fi
        '';
      };
    };

    boot = {
      loader = {
        timeout = 0;
        # Whether the installation process can modify EFI boot variables.
        efi.canTouchEfiVariables = true;
        # Disable kernel command line editor for security
        systemd-boot.editor = false;
      };

      kernelPackages = pkgs.linuxKernel.packages.linux_zen;
      kernel.sysctl."vm.swappiness" = mkDefault 20;

      tmp.useTmpfs = true;
    };

    users = {
      mutableUsers = false;
      users = genAttrs config.abszero.users.admins (const {
        extraGroups = [
          "audio" # For pipeire
          "video" # For wluma and brillo
          "networkmanager"
        ];
      });
      defaultUserShell = pkgs.zsh;
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

    # Certain services freeze on stop which prevents shutdown.
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';

    security = {
      rtkit.enable = true;
      sudo = {
        wheelNeedsPassword = mkDefault false;
        execWheelOnly = true;
      };
    };

    services.journald.console = "/dev/tty1";

    programs.zsh.enable = true;

    # Allow unfree packages
    environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  };
}
