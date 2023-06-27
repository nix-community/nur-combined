{ inputs, modules, ... }:
{ pkgs, ... }:
let
  modules-enable = with modules; [
    avahi
    common
    nix
    sops
    users
  ];
in
{
  imports = map (x: x.default or { }) modules-enable;

  _module.args.settings = { };

  nix.settings = {
    substituters = [
      "http://local.local:5000"
    ];
    trusted-public-keys = [
      "local.local-1:rkw0zf/GEln2K7PKAkMH2JtJfaACnMXEl1OGteT1AHE="
    ];
  };
}
