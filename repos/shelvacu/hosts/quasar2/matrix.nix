{
  pkgs,
  config,
  lib,
  ...
}:
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

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];

  services.postgresql = {
    enable = true;
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [ "matrix-synapse" ];
  };

  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = "consortium.chat";
      database_type = "psycopg2";
      database_args.database = "matrix-synapse";
      old_signing_keys = {
        # verified against:
        # - matrix.org
        # - blatant-lizardry.moe
        "ed25519:a_hhuL" = {
          key = "yB9wA2+2H6bQyf2eGKvn9N2CYFLe4r3OQeW9yf5e5cM";
          expired_ts = 1664953149738; # 2022-10-05T06:59:09Z
        };
        # verified against
        # - matrix.org
        # - blatant-lizardry.moe
        # - uninsane.org
        # - the quasar backup
        "ed25519:a_URkN" = {
          key = "Ol/RoXQEWJPvXv++M901kd51XzN4MhvonPbnqMnGE+E";
          expired_ts = 1778773012052; # 2026-05-14T15:36:52Z
        };
      };
    };
    extraConfigFiles = [ config.sops.secrets.matrix-synapse-secrets.path ];
  };

  services.caddy.virtualHosts = {
    ${"http://" + canonicalDomain}.extraConfig =
      let
        wellknown = {
          server = builtins.toJSON { "m.server" = "${delegatedDomain}:443"; };
          client = builtins.toJSON { "m.homeserver".base_url = "https://${delegatedDomain}"; };
        };
      in
      ''
        header Strict-Transport-Security "max-age=63072000; includeSubDomains"

        header /.well-known/matrix/server Content-Type application/json
        respond /.well-known/matrix/server `${wellknown.server}` 200

        header /.well-known/matrix/client Content-Type application/json
        header /.well-known/matrix/client Access-Control-Allow-Origin *
        respond /.well-known/matrix/client `${wellknown.client}` 200

        reverse_proxy localhost:8008
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
}
