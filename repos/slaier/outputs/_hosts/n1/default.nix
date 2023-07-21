{ modules, ... }:
{ lib, ... }:
let
  modules-enable = with modules; [
    avahi
    clash
    common
    extlinux
    nix
    openfortivpn
    qinglong
    smartdns
    sops
    users
  ];
in
{
  imports = map (x: x.default or { }) modules-enable;

  nix.settings = {
    substituters = [
      "http://local.local:5000"
    ];
    trusted-public-keys = [
      "local-1:rkw0zf/GEln2K7PKAkMH2JtJfaACnMXEl1OGteT1AHE="
    ];
  };

  documentation.man.enable = false;
}
