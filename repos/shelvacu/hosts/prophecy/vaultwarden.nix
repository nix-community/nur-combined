{ lib, ... }:
let
  port = 14983;
  domain = "vaultwarden.shelvacu.com";
in
{
  services.vaultwarden = {
    enable = true;
    # environmentFile = env_path;
    config = {
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;
    };
  };

  services.caddy.virtualHosts.${domain} = {
    vacu.hsts = "preload";
    extraConfig = ''
      reverse_proxy http://127.0.0.1:${toString port}
    '';
  };

  systemd.services.vaultwarden.serviceConfig = {
    RestrictAddressFamilies = lib.mkForce [ "AF_INET" ];
    SocketBindAllow = [ "tcp:${toString port}" ];
    SocketBindDeny = "any";

    # this stops dns and favicon lookups, so nevermind i guess
    # IPAddressAllow = [ "127.0.0.1" ];
    # IPAddressDeny = "any";
  };
}
