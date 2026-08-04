{
  lib,
  config,
  ...
}:
with lib;
{
  options.eownerdead.gnome = mkEnableOption (mdDoc ''
    Enable GNOME desktop
  '');

  config = mkIf config.eownerdead.gnome {
    eownerdead = {
      sound = true;
    };
    services = {
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      gnome = {
        gnome-browser-connector.enable = false;
        gnome-keyring.enable = lib.mkForce false;
      };
    };
  };
}
