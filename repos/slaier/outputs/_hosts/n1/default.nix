{ modules, ... }:
{ lib, pkgs, ... }:
let
  modules-enable = with modules; [
    avahi
    clash
    common
    extlinux
    nix
    smartdns
    sops
    users
  ];
in
{
  imports = map (x: x.default or { }) modules-enable;

  environment.systemPackages = with pkgs; [
    legendary-gl
    tmux
  ];

  nix.settings = {
    trusted-public-keys = [
      "local-1:rkw0zf/GEln2K7PKAkMH2JtJfaACnMXEl1OGteT1AHE="
    ];
  };

  documentation.man.enable = false;
}
