{ inputs, modules, ... }:
{ pkgs, ... }:
let
  modules-enable = with modules; [
    common
    nix
    sops
    users
  ];
in
{
  imports = map (x: x.default or { }) modules-enable;
}
