{ config, lib, pkgs, ... }:

let
  install-bluetooth = pkgs.static-nix-shell.mkBash {
    pname = "install-bluetooth";
    srcRoot = ./.;
    pkgs = [ "gnused" ];
  };
in
lib.optionalAttrs false  #< disabled 2024-09-27 while i rework sane.fs
{
  config = lib.mkIf config.sane.roles.client {
    # persist external pairings by default
    sane.persist.sys.byStore.plaintext = [ "/var/lib/bluetooth" ];  #< TODO: port to private, but may be tricky to ensure service dependencies

    sane.fs."/var/lib/bluetooth".dir.acl.mode = "0700";
    systemd.services.bluetooth-provision-secrets = {
      before = [ "bluetooth.service" ];
      wantedBy = [ "bluetooth.service" ];
      serviceConfig.ExecStart = ''${lib.getExe install-bluetooth} /run/secrets/bt "" ""'';
      serviceConfig.Type = "oneshot";
    };
  };
}
