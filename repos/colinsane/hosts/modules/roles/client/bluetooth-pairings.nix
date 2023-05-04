{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.sane.roles.client {
    # persist external pairings by default
    sane.persist.sys.plaintext = [ "/var/lib/bluetooth" ];

    sane.fs."/var/lib/bluetooth".generated.acl.mode = "0700";
    sane.fs."/var/lib/bluetooth/.secrets.stamp" = {
      wantedBeforeBy = [ "bluetooth.service" ];
      # XXX: install-bluetooth uses sed, but that's part of the default systemd unit path, it seems
      generated.script.script = builtins.readFile ../../../../scripts/install-bluetooth + ''
        touch "/var/lib/bluetooth/.secrets.stamp"
      '';
      generated.script.scriptArgs = [ "/run/secrets/bt" ];
    };
  };
}
