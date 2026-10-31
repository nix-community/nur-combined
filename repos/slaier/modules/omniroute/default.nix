{ config, ... }:
let
  dataDir = "/var/lib/omniroute";
  dashboardPort = 20128;
  apiPort = 20129;
  wsPort = 20132;
  containerNames = [
    "omniroute-redis"
    "omniroute"
  ];
in
{
  sops.secrets = {
    omniroute_jwt_secret = { };
    omniroute_api_key_secret = { };
    omniroute_initial_password = { };
  };

  sops.templates."omniroute-env".content = ''
    JWT_SECRET=${config.sops.placeholder.omniroute_jwt_secret}
    API_KEY_SECRET=${config.sops.placeholder.omniroute_api_key_secret}
    INITIAL_PASSWORD=${config.sops.placeholder.omniroute_initial_password}
    REQUIRE_API_KEY=true
    OMNIROUTE_MEMORY_MB=2048
  '';

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 root root -"
    "d ${dataDir}/data 0750 1000 1000 -"
    "d ${dataDir}/redis 0755 999 999 -"
  ];

  systemd.services =
    builtins.listToAttrs (
      map (name: {
        name = "podman-${name}";
        value.serviceConfig.RestartSec = 5;
      }) containerNames
    )
    // {
      podman-network-omniroute = {
        description = "Create the podman network used by OmniRoute";
        wantedBy = [ "multi-user.target" ];
        before = map (name: "podman-${name}.service") containerNames;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${config.virtualisation.podman.package}/bin/podman network exists omniroute \
            || ${config.virtualisation.podman.package}/bin/podman network create omniroute
        '';
      };
    };

  virtualisation = {
    podman.enable = true;
    oci-containers = {
      backend = "podman";
      containers = {
        omniroute-redis = {
          image = "docker.io/library/redis:8.6.5-alpine";
          cmd = [
            "redis-server"
            "--save"
            "60"
            "1"
            "--loglevel"
            "warning"
          ];
          volumes = [ "${dataDir}/redis:/data" ];
          networks = [ "omniroute" ];
        };

        omniroute = {
          image = "docker.io/diegosouzapw/omniroute:3.8.52";
          dependsOn = [ "omniroute-redis" ];
          environment = {
            DATA_DIR = "/app/data";
            REDIS_URL = "redis://omniroute-redis:6379";
            CONTAINER_RUNTIME = "podman";
            # Bind to the container interface so published ports work.
            DASHBOARD_PORT = toString dashboardPort;
            API_PORT = toString apiPort;
            API_HOST = "0.0.0.0";
            OMNIROUTE_SERVER_HOST = "0.0.0.0";
            LIVE_WS_HOST = "0.0.0.0";
          };
          # Do not pass the host proxy env (127.0.0.1) into the container,
          # where it points at nothing.
          extraOptions = [ "--http-proxy=false" ];
          environmentFiles = [ config.sops.templates."omniroute-env".path ];
          volumes = [ "${dataDir}/data:/app/data" ];
          ports = [
            "127.0.0.1:${toString dashboardPort}:${toString dashboardPort}"
            "127.0.0.1:${toString apiPort}:${toString apiPort}"
            "127.0.0.1:${toString wsPort}:${toString wsPort}"
          ];
          networks = [ "omniroute" ];
        };
      };
    };
  };
}
