{ lib, pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    fuzzel
    niriswitcher
    swaylock
    wayland-pipewire-idle-inhibit
    xwayland-satellite
  ];
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${lib.getExe pkgs.greetd.tuigreet} --cmd niri-session";
    };
  };
}
