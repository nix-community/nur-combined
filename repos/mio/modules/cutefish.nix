# Cutefish Wayland desktop. The session shows up as "Cutefish (Wayland)" in an
# existing display manager. cutefish-dm stays a separate package and is not enabled.
#
# Package installation follows Plasma and GNOME: the shell is required, the
# default applications can be dropped with environment.cutefish.excludePackages,
# and there is no single joined package.
{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  cfg = config.services.desktopManager.cutefish;
  # The NUR overlay puts the package groups on pkgs.cutefish. Importing only
  # this module still builds them from the same expressions.
  cu =
    if pkgs ? cutefish && pkgs.cutefish ? corePackages then
      pkgs.cutefish
    else
      pkgs.callPackage ../by-name/cu/cutefish/scope.nix { };
in
{
  imports = [
    (lib.mkRemovedOptionModule [ "services" "desktopManager" "cutefish" "package" ] ''
      The Cutefish module installs the shell and the default applications itself.
      Drop an application with environment.cutefish.excludePackages.
    '')
  ];

  options = {
    services.desktopManager.cutefish = {
      enable = lib.mkEnableOption "Cutefish Wayland desktop (https://cutefish.org/)";
    };

    environment.cutefish.excludePackages = lib.mkOption {
      description = "List of default Cutefish applications to exclude from the environment.";
      type = lib.types.listOf lib.types.package;
      default = [ ];
      example = lib.literalExpression "[ pkgs.cutefish-video-player ]";
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = lib.optional (!config.services.displayManager.enable) ''
      services.desktopManager.cutefish.enable registers the Cutefish Wayland session.
      Enable a display manager such as services.displayManager.sddm.enable to log in to it.
    '';

    services.displayManager.sessionPackages = [ cu.cutefish-core ];
    services.displayManager.defaultSession = lib.mkDefault "cutefish-wayland";

    environment.systemPackages =
      cu.corePackages
      ++ utils.removePackagesByName cu.optionalPackages config.environment.cutefish.excludePackages
      ++ [
        pkgs.adwaita-icon-theme
        pkgs.hwdata
        pkgs.shared-mime-info
        pkgs.xkeyboard-config
        pkgs.xdg-user-dirs
        pkgs.xdg-utils
      ];

    # xdg.icons links /share/icons, and /lib already covers Qt plugins.
    # Wallpapers and session files are looked up under /run/current-system/sw.
    environment.pathsToLink = [
      "/share/backgrounds"
      "/share/wayland-sessions"
    ];

    services.graphical-desktop.enable = true;
    qt.enable = lib.mkDefault true;
    hardware.graphics.enable = lib.mkDefault true;
    programs.xwayland.enable = lib.mkDefault true;

    services.udev.packages = [ cu.cutefish-core ];
    services.dbus.packages = [ cu.cutefish-core ];
    # Privacy, locales and the session. The portal unit comes in with extraPortals.
    systemd.packages = [ cu.cutefish-core ];

    security.polkit.enable = true;
    # The lock screen calls pam_start("cutefish-auth") and must not open a login session.
    security.pam.services.cutefish-auth = {
      startSession = false;
      setEnvironment = false;
    };

    services.accounts-daemon.enable = lib.mkDefault true;
    services.udisks2.enable = lib.mkDefault true;
    services.upower.enable = lib.mkDefault true;
    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.gnome.gnome-keyring.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;
    networking.networkmanager.enable = lib.mkDefault true;

    services.pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      wireplumber.enable = lib.mkDefault true;
    };

    # cutefish-core ships lib/modules-load.d/cutefish-ddc.conf, which NixOS does not load.
    boot.kernelModules = [ "i2c-dev" ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [
        cu.xdg-desktop-portal-cutefish
        pkgs.xdg-desktop-portal-gtk
      ];
      # share/xdg-desktop-portal/cutefish-portals.conf. The portal lowercases
      # XDG_CURRENT_DESKTOP=Cutefish before looking that file up.
      configPackages = lib.mkDefault [ cu.xdg-desktop-portal-cutefish ];
    };
  };
}
