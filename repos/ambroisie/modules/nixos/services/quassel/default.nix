# An IRC client daemon
{ config, lib, ... }:
let
  cfg = config.my.services.quassel;
  domain = config.networking.domain;
in
{
  options.my.services.quassel = with lib; {
    enable = mkEnableOption "Quassel IRC client daemon";
    port = mkOption {
      type = types.port;
      default = 4242;
      example = 8080;
      description = "The port number for Quassel";
    };
  };

  config = lib.mkIf cfg.enable {
    services.quassel = {
      enable = true;
      portNumber = cfg.port;
      # Let's be secure
      requireSSL = true;
      certificateFile = config.security.acme.certs."${domain}".directory + "/full.pem";
      # The whole point *is* to connect from other clients
      interfaces = [ "0.0.0.0" ];
    };

    # Allow Quassel to read the certificates.
    users.groups.acme.members = [ "quassel" ];

    # Open port for Quassel
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # Create storage DB
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "quassel" ];
      ensureUsers = [
        {
          name = "quassel";
          ensureDBOwnership = true;
        }
      ];
      # Insecure, I don't care.
      # Because Quassel does not use the socket, I simply trust its connection
      authentication = "host quassel quassel localhost trust";
    };
  };
}
