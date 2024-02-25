{ config, lib, pkgs, ... }:

let
  install-nm = pkgs.static-nix-shell.mkPython3Bin {
    pname = "install-nm";
    srcRoot = ./.;
  };
in
{
  config = lib.mkIf config.sane.roles.client {
    sane.fs."/var/lib/iwd/.install-nm.stamp" = {
      wantedBeforeBy = [ "iwd.service" ];
      generated.acl.mode = "0600";
      generated.command = [
        "${install-nm}/bin/install-nm"
        "/run/secrets/net/all.json"
        "/var/lib/iwd"
        "--stamp" ".install-nm.stamp"
        "--flavor" "iwd"
      ];
    };

    sane.fs."/var/lib/NetworkManager/system-connections".dir.acl.mode = "0700";
    sane.fs."/var/lib/NetworkManager/system-connections/.install-nm.stamp" = {
      wantedBeforeBy = [ "NetworkManager.service" ];
      generated.acl.mode = "0600";
      generated.command = [
        "${install-nm}/bin/install-nm"
        "/run/secrets/net/all.json"
        "/var/lib/NetworkManager/system-connections"
        "--stamp" ".install-nm.stamp"
        "--flavor" "nm"
      ];
    };
  };
}
