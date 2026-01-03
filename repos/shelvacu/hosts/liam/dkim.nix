{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.vacu.liam) domains;
in
{
  services.opendkim = {
    enable = true;
    keyPath = "/run/secrets/dkimkeys";
    domains = "file:${pkgs.writeText "SignDomains" (lib.concatStringsSep "\n" domains)}";
    selector = "2024-03-liam";
    socket = "local:/run/opendkim/opendkim.sock";
    inherit (config.services.postfix) group user;
  };
  systemd.services.postfix = {
    wants = [ "opendkim.service" ];
    after = [ "opendkim.service" ];
  };
}
