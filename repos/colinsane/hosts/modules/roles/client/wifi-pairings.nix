{ config, lib, pkgs, ... }:

{
  config = lib.mkIf config.sane.roles.client {
    sane.fs."/var/lib/iwd/.secrets.psk.stamp" = {
      wantedBeforeBy = [ "iwd.service" ];
      generated.acl.mode = "0600";
      # XXX: install-iwd uses sed, but that's part of the default systemd unit path, it seems
      generated.script.script = builtins.readFile ../../../../scripts/install-iwd + ''
        touch "/var/lib/iwd/.secrets.psk.stamp"
      '';
      generated.script.scriptArgs = [ "/run/secrets/iwd" "/var/lib/iwd" ];
    };
  };
}
