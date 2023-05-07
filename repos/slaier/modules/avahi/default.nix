{ lib, pkgs, ... }:
{
  services.avahi = {
    enable = true;
    nssmdns = false;
    publish = {
      enable = true;
      addresses = true;
    };
  };
  system.nssModules = [ pkgs.nssmdns ];
  system.nssDatabases.hosts = with lib; mkMerge [
    (mkBefore [ "mdns4_minimal [NOTFOUND=return]" ]) # before resolve
    (mkAfter [ "mdns4" ]) # after dns
  ];
}
