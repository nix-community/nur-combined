{ config, pkgs, lib, ... }:
let
  virtualHostConfigs = builtins.filter (x: x != "template.nix")
    (builtins.attrNames (builtins.readDir ./virtualHosts));

  extraConfigs = builtins.map (x: (import ./config/${x} { inherit config; }))
    (builtins.attrNames (builtins.readDir ./config));

  subdomains = builtins.attrNames config.services.nginx.virtualHosts;

  tld = "rovacsek.com";

  virtualHosts = builtins.foldl' (x: y: x // y) { }
    (builtins.map (x: (import ./virtualHosts/${x} { inherit config tld; }))
      virtualHostConfigs);
in {
  # Require TLS certs
  imports = [
    (import ../acme {
      inherit subdomains config;
      primaryDomain = tld;
    })
    # Load all *.nix files from the config directory
  ] ++ extraConfigs;

  ## TODO: read into: https://github.com/kreativmonkey/nixos-config/blob/c5c543a07d75a53df251631cec7d47a4390aaebc/modules/authentik.nix

  services.nginx = {
    enable = true;

    inherit virtualHosts;

    config = ''
      pcre_jit on;

      include /etc/nginx/modules/*.conf;

      events {
          # The maximum number of simultaneous connections that can be opened by
          # a worker process.
          worker_connections 1024;
          # multi_accept on;
      }

      http {
          default_type application/octet-stream;

          server_tokens off;

          client_max_body_size 0;

          sendfile on;

          tcp_nopush on;

          # Helper variable for proxying websockets.
          map $http_upgrade $connection_upgrade {
              default upgrade;
              \'\' close;
          }

          client_body_buffer_size 128k;
          keepalive_timeout 65;
          large_client_header_buffers 4 16k;
          send_timeout 5m;
          tcp_nodelay on;
          types_hash_max_size 2048;
          variables_hash_max_size 2048;
          # server_names_hash_bucket_size 64;
          # server_name_in_redirect off;

          gzip on;
          gzip_disable "msie6";
      }
    '';

    # DNS Resolution
    resolver = {
      ipv6 = false;
      # The below shouldn't be required as 
      addresses = [ "192.168.6.1" ];
    };
    proxyResolveWhileRunning = true;

    proxyTimeout = "10s";

    # Apply recommended TLS settings
    recommendedTlsSettings = true;

    # Apply recommended optimisation settings
    recommendedOptimisation = true;

    # Apply recommended proxy settings if a vhost does not specify the option manually
    recommendedProxySettings = true;

    # Config to define http common settings
    # commonHttpConfig = ''
    #   resolver 127.0.0.1 valid=5s;

    #   log_format myformat '$remote_addr - $remote_user [$time_local] '
    #                       '"$request" $status $body_bytes_sent '
    #                       '"$http_referer" "$http_user_agent"';
    # '';

    # Unused unless we want to proxy games/stream items via nginx
    # streamConfig = ''
    #   server {
    #     listen 127.0.0.1:53 udp reuseport;
    #     proxy_timeout 20s;
    #     proxy_pass 192.168.0.1:53535;
    #   }
    # '';
  };
}
