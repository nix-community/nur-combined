{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) genAttrs const mkDefault;
in

{
  abszero.boot = {
    loader.systemd-boot.enable = true;
    quiet = true;
  };

  nix = {
    package = pkgs.nixVersions.latest;
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
      substituters = [ "https://abszero.cachix.org" ];
      trusted-public-keys = [ "abszero.cachix.org-1:HXOydaS51jSWrM07Ko8AVtGdoBRT9F+QhdYQBiNDaM0=" ];
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
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff \
          /run/current-system "$systemConfig"
      '';
    };
  };

  boot = {
    # Whether the installation process can modify EFI boot variables.
    loader.efi.canTouchEfiVariables = true;

    kernelPackages = pkgs.linuxPackages_zen;
    kernel.sysctl."vm.swappiness" = mkDefault 20;

    tmp.useTmpfs = true;
  };

  users = {
    mutableUsers = false;
    users = genAttrs config.abszero.users.admins (const {
      extraGroups = [
        "audio"
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

  # Certain services freeze on stop which prevents shutdown.
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  security = {
    rtkit.enable = true;
    sudo = {
      wheelNeedsPassword = false;
      execWheelOnly = true;
    };
  };

  services.journald.console = "/dev/tty1";

  # Allow unfree packages
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
}
