{ config, lib, pkgs, ... }:

let
  install-bluetooth = pkgs.static-nix-shell.mkBash {
    pname = "install-bluetooth";
    srcRoot = ./.;
    pkgs = [ "gnused" ];
  };
in
{
  config = lib.mkIf config.sane.roles.client {
    # persist external pairings by default
    sane.persist.sys.byStore.plaintext = [ "/var/lib/bluetooth" ];

    sane.fs."/var/lib/bluetooth".generated.acl.mode = "0700";
    sane.fs."/var/lib/bluetooth/.secrets.stamp" = {
      wantedBeforeBy = [ "bluetooth.service" ];
      generated.command = [
        "${install-bluetooth}/bin/install-bluetooth"
        "/run/secrets/bt"
        ""
        "/var/lib/bluetooth/.secrets.stamp"
      ];
    };
  };
}
