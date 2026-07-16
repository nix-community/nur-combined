{

  flake.modules.nixos.bub =
    {
      pkgs,
      lib,
      ...
    }:
    let
      sourceDir = "/home/agent/bub";
      stateDir = "/var/lib/bub";
    in
    {
      virtualisation.oci-containers.containers."bub" = {
        image = "localhost/compose2nix/bub";
        environment = {
          BUB_API_BASE = "http://cliproxyapi:8317/v1";
          BUB_API_KEY = "sk-thisisapublicsecretinaverylocalenv";
          BUB_MODEL = "openai:gemini-3.1-pro-preview";
          BUB_ENABLED_CHANNELS = "all";
          BUB_HOME = "/data";
          BUB_SEARCH_SEARXNG_DEFAULT_LANGUAGE = "zh-CN";
          BUB_SEARCH_SEARXNG_USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36";
          BUB_TAPESTORE_REDIS_URL = "redis://tapestoredis:6379/0";
          BUB_TELEGRAM_ALLOW_CHATS = "-5291037862,-1002215131569,454999736,6280888824";
          BUB_TELEGRAM_ALLOW_USERS = "454999736,6280888824";
          BUB_SEARCH_SEARXNG_BASE_URL = "http://searxng:8080";
        };
        environmentFiles = [ "/var/lib/bub/env" ];
        volumes = [
          "${stateDir}/.agents:/root/.agents:rw"
          "/${sourceDir}:/workspace:rw"
          "${stateDir}/data:/data:rw"
        ];
        dependsOn = [
          "searxng"
          "tapestoredis"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=app"
          "--network=bub_internal_net"
        ];
      };
      systemd.services."podman-bub" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        after = [
          "podman-network-bub_internal_net.service"
        ];
        requires = [
          "podman-network-bub_internal_net.service"
        ];
        partOf = [
          "podman-compose-bub-root.target"
        ];
        wantedBy = [
          "podman-compose-bub-root.target"
        ];
      };
      virtualisation.oci-containers.containers."searxng" = {
        image = "searxng/searxng:latest";
        environment = {
          "SEARXNG_BASE_URL" = "http://localhost:8080/";
          "SEARXNG_HOST" = "[::]";
          "SEARXNG_PORT" = "8080";
        };
        ports = [
          "8080:8080/tcp"
        ];
        volumes = [
          "/var/lib/bub/searxng_settings.yml:/etc/searxng/settings.yml:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=searxng"
          "--network=bub_internal_net"
          "--no-healthcheck"
        ];
      };
      systemd.services."podman-searxng" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        after = [
          "podman-network-bub_internal_net.service"
        ];
        requires = [
          "podman-network-bub_internal_net.service"
        ];
        partOf = [
          "podman-compose-bub-root.target"
        ];
        wantedBy = [
          "podman-compose-bub-root.target"
        ];
      };
      virtualisation.oci-containers.containers."tapestoredis" = {
        image = "redis:alpine";
        volumes = [
          "bub_redis_data:/data:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=tapestoredis"
          "--network=bub_internal_net"
        ];
      };
      systemd.services."podman-tapestoredis" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        after = [
          "podman-network-bub_internal_net.service"
          "podman-volume-bub_redis_data.service"
        ];
        requires = [
          "podman-network-bub_internal_net.service"
          "podman-volume-bub_redis_data.service"
        ];
        partOf = [
          "podman-compose-bub-root.target"
        ];
        wantedBy = [
          "podman-compose-bub-root.target"
        ];
      };

      virtualisation.oci-containers.containers."cliproxyapi" = {
        image = "eceasy/cli-proxy-api:latest";
        volumes = [
          "${
            pkgs.writeText "cliproxyapi-config" # yaml
              ''
                # Server host/interface to bind to. Default is empty ("") to bind all interfaces (IPv4 + IPv6).
                host: ""

                # Server port
                port: 8317

                # TLS settings for HTTPS.
                tls:
                  enable: false
                  cert: ""
                  key: ""

                # Management API settings
                remote-management:
                  allow-remote: false
                  secret-key: ""
                  disable-control-panel: false
                  panel-github-repository: "https://github.com/router-for-me/Cli-Proxy-API-Management-Center"

                # Authentication directory
                auth-dir: "~/.cli-proxy-api"

                # API keys for authentication (used to access this proxy server)
                api-keys:
                  - "sk-thisisapublicsecretinaverylocalenv"

                # Enable debug logging
                debug: false

                # Proxy URL. Supports socks5/http/https protocols.
                proxy-url: ""

                # Number of times to retry a request.
                request-retry: 3

                # Quota exceeded behavior
                quota-exceeded:
                  switch-project: true
                  switch-preview-model: true
                  antigravity-credits: true

                # Routing strategy for selecting credentials when multiple match.
                routing:
                  strategy: "round-robin"
                  session-affinity: false
                  session-affinity-ttl: "1h"

                # Signature cache validation for thinking blocks (Antigravity/Claude).
                # antigravity-signature-cache-enabled: true
                # antigravity-signature-bypass-strict: false

                # Global OAuth model name aliases
                # Mapping the upstream Antigravity model to a client-visible OpenAI-compatible alias
                oauth-model-alias:
                  antigravity:
                    - name: "gemini-pro-agent"          # upstream Antigravity model id
                      alias: "gemini-3.1-pro-preview"   # client-visible id
                      fork: true
                      force-mapping: true

                # OAuth provider excluded models
                oauth-excluded-models:
                  antigravity:
                    - "gemini-3-pro-preview"
              ''
          }:/CLIProxyAPI/config.yaml:rw"
          "${stateDir}/cliproxyapi/auth-dir:/root/.cli-proxy-api:rw"
          "${stateDir}/cliproxyapi/plugins:/CLIProxyAPI/plugins:rw"
        ];
        log-driver = "journald";
        extraOptions = [
          "--network-alias=cliproxyapi"
          "--network=bub_internal_net"
        ];
      };
      systemd.services."podman-cliproxyapi" = {
        serviceConfig = {
          Restart = lib.mkOverride 90 "always";
        };
        after = [
          "podman-network-bub_internal_net.service"
        ];
        requires = [
          "podman-network-bub_internal_net.service"
        ];
        partOf = [
          "podman-compose-bub-root.target"
        ];
        wantedBy = [
          "podman-compose-bub-root.target"
        ];
      };

      # Networks
      systemd.services."podman-network-bub_internal_net" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStop = "podman network rm -f bub_internal_net";
        };
        script = ''
          podman network inspect bub_internal_net || podman network create bub_internal_net --driver=bridge
        '';
        partOf = [ "podman-compose-bub-root.target" ];
        wantedBy = [ "podman-compose-bub-root.target" ];
      };

      # Volumes
      systemd.services."podman-volume-bub_redis_data" = {
        path = [ pkgs.podman ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          podman volume inspect bub_redis_data || podman volume create bub_redis_data
        '';
        partOf = [ "podman-compose-bub-root.target" ];
        wantedBy = [ "podman-compose-bub-root.target" ];
      };

      # Builds
      systemd.services."podman-build-bub" = {
        path = [
          pkgs.podman
          pkgs.git
        ];
        serviceConfig = {
          Type = "oneshot";
          TimeoutSec = 300;
        };
        script = ''
          cd ${sourceDir}
          podman build -t compose2nix/bub .
        '';
      };

      # Root service
      # When started, this will automatically create all resources and start
      # the containers. When stopped, this will teardown all resources.
      systemd.targets."podman-compose-bub-root" = {
        unitConfig = {
          Description = "Root target generated by compose2nix.";
        };
        wantedBy = [ "multi-user.target" ];
      };

    };
}
