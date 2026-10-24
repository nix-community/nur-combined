# Cutefish Wayland desktop. Log in by choosing "Cutefish (Wayland)" in SDDM, GDM
# or LightDM. cutefish-dm is packaged separately and is not enabled here.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.desktopManager.cutefish;
  # The NUR overlay puts these on pkgs. Importing only this module still builds
  # them from the same expressions.
  cutefishPkgs =
    if pkgs ? cutefish-core && pkgs ? cutefish-compositor && pkgs ? xdg-desktop-portal-cutefish then
      pkgs
    else
      pkgs.callPackage ../by-name/cu/cutefish/scope.nix { };
in
{
  options.services.desktopManager.cutefish = {
    enable = lib.mkEnableOption ''
      the Cutefish Wayland desktop (https://cutefish.org/).
      Choose "Cutefish (Wayland)" in your display manager. A display manager
      such as SDDM or GDM has to be enabled separately
    '';

    package = lib.mkPackageOption cutefishPkgs "cutefish" { };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sessionPackages = [ cutefishPkgs.cutefish-core ];

    environment.systemPackages = [
      cfg.package
      pkgs.adwaita-icon-theme
      pkgs.hicolor-icon-theme
      pkgs.hwdata
      pkgs.shared-mime-info
      pkgs.xkeyboard-config
      pkgs.xdg-user-dirs
      pkgs.xdg-utils
    ];

    environment.pathsToLink = [
      "/share/backgrounds"
      "/share/icons"
      "/share/wayland-sessions"
      "/lib/qt-6/plugins"
    ];

    services.graphical-desktop.enable = true;
    qt.enable = lib.mkDefault true;
    hardware.graphics.enable = lib.mkDefault true;
    programs.xwayland.enable = lib.mkDefault true;

    services.udev.packages = [ cutefishPkgs.cutefish-core ];
    services.dbus.packages = [ cutefishPkgs.cutefish-core ];

    security.polkit.enable = true;
    # Lock screen authenticates through PAM service "cutefish-auth" and does not
    # open another login session.
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

    # External brightness. The matching udev rules ship in cutefish-core.
    boot.kernelModules = [ "i2c-dev" ];

    systemd.packages = [
      cutefishPkgs.cutefish-core
      cutefishPkgs.xdg-desktop-portal-cutefish
    ];

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      dejavu_fonts
    ];

    xdg.portal = {
      enable = true;
      extraPortals = [
        cutefishPkgs.xdg-desktop-portal-cutefish
        pkgs.xdg-desktop-portal-gtk
      ];
      config.Cutefish = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Settings" = [
          "cutefish"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "cutefish" ];
        "org.freedesktop.impl.portal.Inhibit" = [ "cutefish" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "cutefish" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };
}
