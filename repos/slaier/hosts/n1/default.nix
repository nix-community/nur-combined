{ nodes, lib, modules, config, ... }:
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

  nix.settings =
    let
      hostname = with nodes.local.config.services.avahi; "${hostName}.${domainName}";
      port = builtins.toString nodes.local.config.services.nix-serve.port;
    in
    {
      substituters = lib.mkForce [
        "http://${hostname}:${port}"
      ];
      trusted-public-keys = lib.mkForce [
        "${hostname}-1:rkw0zf/GEln2K7PKAkMH2JtJfaACnMXEl1OGteT1AHE="
      ];
    };

  documentation.man.enable = false;
}
