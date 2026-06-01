{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.system;
in
{
  options.nixcfg.system.enable = lib.mkEnableOption "system defaults (timezone, locale, stateVersion, autoUpgrade, services, packages)";

  config = lib.mkIf cfg.enable {
    time.timeZone = "America/Chicago";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "C.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "C.UTF-8";
      };
    };

    catppuccin = rec {
      enable = true;
      flavor = "frappe";
      accent = "red";
      tty = {
        enable = true;
        flavor = flavor;
      };
      plymouth.enable = true;
    };

    console.useXkbConfig = true;

    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
      command-not-found.enable = false;
    };

    services = {
      xserver.xkb = {
        layout = "us";
        options = "ctrl:nocaps";
      };
      pcscd.enable = true;
      udev.packages = with pkgs; [ yubikey-personalization ];
      printing.enable = config.nixcfg.gui.enable;
      pipewire = lib.mkIf config.nixcfg.gui.enable {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
      flatpak.enable = config.nixcfg.gui.enable;
      fwupd.enable = true;
    };

    xdg.portal = lib.mkIf config.nixcfg.gui.enable {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    system = {
      stateVersion = "26.05";
      autoUpgrade = {
        enable = true;
        flake = "github:ToyVoDev/nixcfg";
        persistent = true;
        allowReboot = true;
        rebootWindow = {
          lower = "01:00";
          upper = "05:00";
        };
        randomizedDelaySec = "45min";
      };
    };

    security.rtkit.enable = true;

    nix.optimise.automatic = true;

    environment.systemPackages =
      with pkgs;
      [
        cifs-utils
        ghostty.terminfo
      ]
      ++ lib.optionals (config.system.activationScripts ? setupSecrets) [
        (writeShellScriptBin "sops-nix-system" "${config.system.activationScripts.setupSecrets.text}")
      ];
  };
}
