{ pkgs, ... }:

{
  programs.xwayland = {
    enable = true;
    package = pkgs.xwayland-satellite;
  };
  programs.niri.package = pkgs.niri;
  programs.niri.enable = true;
  programs.niri.useNautilus = true;
  systemd.user.services.niri-flake-polkit.enable = false;
  security.soteria.enable = true;
  services.gnome.evolution-data-server.enable = true;
}
