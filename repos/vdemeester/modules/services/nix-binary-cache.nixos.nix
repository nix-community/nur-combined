{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.nix-binary-cache;
in
{
  options = {
    services.nix-binary-cache = {
      enable = mkOption {
        default = false;
        description = "Enable nix-binary-cache";
        type = types.bool;
      };
      domain = mkOption {
        description = "domain to serve";
        type = types.str;
      };
      aliases = mkOption {
        default = [ ];
        description = "server aliases to serve";
        type = types.listOf types.str;
      };
    };
  };
  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      appendHttpConfig = ''
        proxy_cache_path /var/public-nix-cache/ levels=1:2 keys_zone=cachecache:1200m max_size=20g inactive=365d use_temp_path=off;
        # Cache only success status codes; in particular we don't want to cache 404s.
        # See https://serverfault.com/a/690258/128321
        map $status $cache_header {
          200     "public";
          302     "public";
          default "no-cache";
        }
        access_log logs/access.log;
      '';
      virtualHosts."${cfg.domain}" = {
        serverAliases = cfg.aliases;
        # enableACME = true;

        locations."/" = {
          root = "/var/public-nix-cache/";
          extraConfig = ''
            expires max;
            add_header Cache-Control $cache_header always;
            # Ask the upstream server if a file isn't available locally
            error_page 404 = @fallback;
          '';
        };
        extraConfig = ''
          # Using a variable for the upstream endpoint to ensure that it is
          # resolved at runtime as opposed to once when the config file is loaded
          # and then cached forever (we don't want that):
          # see https://tenzer.dk/nginx-with-dynamic-upstreams/
          # This fixes errors like
          #   nginx: [emerg] host not found in upstream "upstream.example.com"
          # when the upstream host is not reachable for a short time when
          # nginx is started.
          resolver 8.8.8.8;
          set $upstream_endpoint https://cache.nixos.org;
        '';
        locations."@fallback" = {
          proxyPass = "$upstream_endpoint";
          extraConfig = ''
            proxy_cache cachecache;
            proxy_cache_valid  200 302  60m;
            expires max;
            add_header Cache-Control $cache_header always;
          '';
        };
        # We always want to copy cache.nixos.org's nix-cache-info file,
        # and ignore our own, because `nix-push` by default generates one
        # without `Priority` field, and thus that file by default has priority
        # 50 (compared to cache.nixos.org's `Priority: 40`), which will make
        # download clients prefer `cache.nixos.org` over our binary cache.
        locations."= /nix-cache-info" = {
          # Note: This is duplicated with the `@fallback` above,
          # would be nicer if we could redirect to the @fallback instead.
          proxyPass = "$upstream_endpoint";
          extraConfig = ''
            proxy_cache cachecache;
            proxy_cache_valid  200 302  60m;
            expires max;
            add_header Cache-Control $cache_header always;
          '';
        };
      };
    };
  };
}
