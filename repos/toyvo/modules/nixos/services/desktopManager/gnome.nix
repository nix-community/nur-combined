{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.desktopManager.gnome;
in
{
  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        displayManager.gdm.enable = true;
      };
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryPackage = pkgs.pinentry-gnome3;
    environment.systemPackages = with pkgs; [
      gnome-extension-manager
      gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.arcmenu
      gnomeExtensions.blur-my-shell
      gnomeExtensions.burn-my-windows
      gnomeExtensions.compiz-alike-magic-lamp-effect
      gnomeExtensions.compiz-windows-effect
      gnomeExtensions.dash-to-dock
      gnomeExtensions.dash-to-panel
      gnomeExtensions.desktop-cube
      gnomeExtensions.extension-list
      gnomeExtensions.just-perfection
      gnomeExtensions.mpris-label
      gnomeExtensions.quick-settings-tweaker
      gnomeExtensions.systemstatsplus
      gnomeExtensions.user-themes
    ];
  };
}
