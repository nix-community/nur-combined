{ modules, ... }:
{ lib, pkgs, ... }:
let
  modules-enable = with modules; [
    common
    extlinux
    nix
    sing-box
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
