{ lib, pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    freefilesync
    fuzzel
    nautilus
    niriswitcher
    swaylock
    tauon
    wl-clipboard-rs
    xwayland-satellite
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${lib.getExe pkgs.tuigreet} --cmd niri-session";
    };
  };
  services.gvfs.enable = true;
}
