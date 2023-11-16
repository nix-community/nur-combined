{ modules, ... }:
{ lib, pkgs, ... }:
let
  modules-enable = with modules; [
    clash
    common
    extlinux
    nix
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

  documentation.man.enable = false;
}
