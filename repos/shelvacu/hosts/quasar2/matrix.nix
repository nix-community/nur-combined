{ pkgs, config, lib, ... }:
let
  canonicalDomain = "consortium.chat";
  delegatedDomain = "matrix.consortium.chat";
  adminAppDomain = "admin.consortium.chat";
in
{
  sops.secrets.matrix-synapse-secrets = {
    owner = "matrix-synapse";
    mode = "400";
    restartUnits = [ "matrix-synapse.service" ];
    key = "";
  };

  services.caddy.enable = true;
  services.caddy.globalConfig = ''
    servers {
      trusted_proxies static 10.78.77.1/32
    }
  '';

  networking.firewall.allowedTCPPorts = [ 443 80 ];

  services.postgresql = {
    enable = true;
    ensureUsers = [ {
      name = "matrix-synapse";
      ensureDBOwnership = true;
    } ];
    ensureDatabases = [ "matrix-synapse" ];
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "consortium.chat";
      database_type = "psycopg2";
      database_args.database = "matrix-synapse";
    };
    extraConfigFiles = [ config.sops.secrets.matrix-synapse-secrets.path ];
  };

  services.caddy.virtualHosts = {
    ${"http://" + canonicalDomain}.extraConfig =
      let
        wellknown = {
          server = builtins.toJSON { "m.server" = "${delegatedDomain}:443"; };
          client = builtins.toJSON {
            "m.homeserver".base_url = "https://${delegatedDomain}";
          };
        };
      in
      ''
        respond /.well-known/matrix/server `${wellknown.server}` 200
        respond /.well-known/matrix/client `${wellknown.client}` 200
        reverse_proxy localhost:8008
        header Strict-Transport-Security "max-age=63072000; includeSubDomains"
      '';
    ${"http://" + delegatedDomain}.extraConfig = ''
      reverse_proxy /_matrix/* localhost:8008
      reverse_proxy /_synapse/client/* localhost:8008
    '';
    ${"http://" + adminAppDomain}.extraConfig = ''
      root * ${pkgs.synapse-admin}
      file_server
    '';
  };

  vacu.systemKind = lib.mkDefault "minimal";

  networking.useNetworkd = true;
  systemd.network.enable = true;
  # Match any ethernet interface (there is exactly one: the virtio-net NIC)
  systemd.network.networks."10-eth" = {
    matchConfig.Type = "ether";
    networkConfig = {
      DHCP = "no";
      Address = "10.78.77.3/24";
      Gateway = "10.78.77.1";
      DNS = "10.78.79.1";
    };
  };
}
