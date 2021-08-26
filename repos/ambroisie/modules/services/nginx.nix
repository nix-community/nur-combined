# A simple abstraction layer for almost all of my services' needs
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.nginx;

  virtualHostOption = with lib; types.submodule {
    options = {
      subdomain = mkOption {
        type = types.str;
        example = "dev";
        description = ''
          Which subdomain, under config.networking.domain, to use
          for this virtual host.
        '';
      };

      port = mkOption {
        type = with types; nullOr port;
        default = null;
        example = 8080;
        description = ''
          Which port to proxy to, through 127.0.0.1, for this virtual host.
          This option is incompatible with `root`.
        '';
      };

      root = mkOption {
        type = with types; nullOr path;
        default = null;
        example = "/var/www/blog";
        description = ''
          The root folder for this virtual host.  This option is incompatible
          with `port`.
        '';
      };

      extraConfig = mkOption {
        type = types.attrs; # FIXME: forward type of virtualHosts
        example = litteralExample ''
          {
            locations."/socket" = {
              proxyPass = "http://127.0.0.1:8096/";
              proxyWebsockets = true;
            };
          }
        '';
        default = { };
        description = ''
          Any extra configuration that should be applied to this virtual host.
        '';
      };
    };
  };
in
{
  options.my.services.nginx = with lib; {
    enable =
      mkEnableOption "Nginx, activates when `virtualHosts` is not empty" // {
        default = builtins.length cfg.virtualHosts != 0;
      };

    monitoring = {
      enable = my.mkDisableOption "monitoring through grafana and prometheus";
    };

    virtualHosts = mkOption {
      type = types.listOf virtualHostOption;
      default = [ ];
      example = litteralExample ''
        [
          {
            subdomain = "gitea";
            port = 8080;
          }
          {
            subdomain = "dev";
            root = "/var/www/dev";
          }
          {
            subdomain = "jellyfin";
            port = 8096;
            extraConfig = {
              locations."/socket" = {
                proxyPass = "http://127.0.0.1:8096/";
                proxyWebsockets = true;
              };
            };
          }
        ]
      '';
      description = ''
        List of virtual hosts to set-up using default settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [ ]
      ++ (lib.flip builtins.map cfg.virtualHosts ({ subdomain, ... } @ args:
      let
        conflicts = [ "port" "root" ];
        optionsNotNull = builtins.map (v: args.${v} != null) conflicts;
        optionsSet = lib.filter lib.id optionsNotNull;
      in
      {
        assertion = builtins.length optionsSet == 1;
        message = ''
          Subdomain '${subdomain}' must have exactly one of ${
            lib.concatStringsSep ", " (builtins.map (v: "'${v}'") conflicts)
          } configured.
        '';
      }))
      ++ (
      let
        ports = lib.my.mapFilter
          (v: v != null)
          ({ port, ... }: port)
          cfg.virtualHosts;
        portCounts = lib.my.countValues ports;
        nonUniquesCounts = lib.filterAttrs (_: v: v != 1) portCounts;
        nonUniques = builtins.attrNames nonUniquesCounts;
        mkAssertion = port: {
          assertion = false;
          message = "Port ${port} cannot appear in multiple virtual hosts.";
        };
      in
      map mkAssertion nonUniques
    ) ++ (
      let
        subs = map ({ subdomain, ... }: subdomain) cfg.virtualHosts;
        subsCounts = lib.my.countValues subs;
        nonUniquesCounts = lib.filterAttrs (_: v: v != 1) subsCounts;
        nonUniques = builtins.attrNames nonUniquesCounts;
        mkAssertion = v: {
          assertion = false;
          message = ''
            Subdomain '${v}' cannot appear in multiple virtual hosts.
          '';
        };
      in
      map mkAssertion nonUniques
    )
    ;

    services.nginx = {
      enable = true;
      statusPage = true; # For monitoring scraping.

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;

      virtualHosts =
        let
          domain = config.networking.domain;
          mkVHost = ({ subdomain, ... } @ args: lib.nameValuePair
            "${subdomain}.${domain}"
            (builtins.foldl' lib.recursiveUpdate { } [
              # Base configuration
              {
                forceSSL = true;
                useACMEHost = domain;
              }
              # Proxy to port
              (lib.optionalAttrs (args.port != null) {
                locations."/".proxyPass =
                  "http://127.0.0.1:${toString args.port}";
              })
              # Serve filesystem content
              (lib.optionalAttrs (args.root != null) {
                inherit (args) root;
              })
              # VHost specific configuration
              args.extraConfig
            ])
          );
        in
        lib.my.genAttrs' cfg.virtualHosts mkVHost;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # Nginx needs to be able to read the certificates
    users.users.nginx.extraGroups = [ "acme" ];

    security.acme = {
      email = "bruno.acme@belanyi.fr";
      acceptTerms = true;
      # Use DNS wildcard certificate
      certs =
        let
          domain = config.networking.domain;
          key = config.my.secrets.acme.key;
        in
        with pkgs;
        {
          "${domain}" = {
            extraDomainNames = [ "*.${domain}" ];
            dnsProvider = "gandiv5";
            credentialsFile = writeText "key.env" key; # Unsecure, I don't care.
          };
        };
    };

    services.grafana.provision.dashboards = lib.mkIf cfg.monitoring.enable [
      {
        name = "NGINX";
        options.path = pkgs.nur.repos.alarsyo.grafanaDashboards.nginx;
        disableDeletion = true;
      }
    ];

    services.prometheus = lib.mkIf cfg.monitoring.enable {
      exporters.nginx = {
        enable = true;
        listenAddress = "127.0.0.1";
      };

      scrapeConfigs = [
        {
          job_name = "nginx";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
      ];
    };
  };
}
