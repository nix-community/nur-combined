# original from NickCao/flakes
{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.repack.caddy;
  format = pkgs.formats.json { };
  configfile = format.generate "config.json" cfg.settings;
in
{

  options = {
    repack.caddy = {
      # moved to upper module
      # enable = lib.mkEnableOption "caddy api gateway";
      # mkPackageOption not work here
      public = lib.mkEnableOption "shared certificate storage, and API env";
      package = lib.mkOption {
        type = lib.types.package;
        default =
          (pkgs.callPackage "${pkgs.path}/pkgs/by-name/ca/caddy/plugins.nix" {
            caddy = (
              (pkgs.callPackage "${pkgs.path}/pkgs/by-name/ca/caddy/package.nix" {
                buildGoModule = pkgs.buildGo124Module;
              }).overrideAttrs
                (
                  final: prev:
                  let
                    version = "2.10.0-beta.1";
                  in
                  {
                    inherit version;
                    src = pkgs.fetchFromGitHub {
                      owner = "caddyserver";
                      repo = "caddy";
                      rev = "v${version}";
                      hash = "sha256-3YDpcCgHuOnn7BhjS5KWNr44ADb4+J4l+8QRDL7WGFg=";
                    };
                    vendorHash = "sha256-YQLd+Xn1MfBUoY/LA0PwT/LlPaxNOg/HEN5B0jcs5VA=";
                  }
                )
            );
          })
            {
              plugins = [
                "github.com/caddy-dns/cloudflare@v0.0.0-20250228175314-1fb64108d4de"
                "github.com/mholt/caddy-ratelimit@v0.1.0"
                "github.com/ss098/certmagic-s3@v0.0.0-20240919074713-f227064b6744"
              ];
              hash = "sha256-Z8Mrl2jKfHK/hVPRCG5bQ/sHbDj0n15Vbj2kb5iwMO4=";
            };
      };
      settings = lib.mkOption {
        type = lib.types.submodule { freeformType = format.type; };
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    repack.caddy.settings = {
      admin = {
        config.persist = false;
      };
      logging.logs.debug.level = "debug";
      storage = mkIf cfg.public {
        module = "s3";
        host = "ad73318a13b24f38bd07b54222ad9e01.r2.cloudflarestorage.com";
        bucket = "cert";
        prefix = "ssl";
        insecure = false;
      };
      apps = {
        http.grace_period = "1s";
        http.servers.srv0 = {
          listen = [ ":443" ];
          strict_sni_host = false;
          automatic_https = {
            skip_certificates = [
            ];
            prefer_wildcard = true;
          };
          routes = [
            {
              match = [
                {
                  host = [ config.networking.fqdn ];
                  path = [ "/caddy" ];
                }
              ];
              handle = [
                {
                  handler = "authentication";
                  providers.http_basic.accounts = [
                    {
                      username = "prometheus";
                      password = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
                    }
                  ];
                }
                { handler = "metrics"; }
              ];
            }
          ];
          metrics = { };
        };
      };
    };

    environment.etc."caddy/config.json".source = configfile;
    environment.systemPackages = [ cfg.package ];

    systemd.services.caddy = {
      preStart = "cp -f /etc/caddy/config.json /var/lib/caddy/backup.json";
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      serviceConfig =
        let
          caddyBin = "${cfg.package}/bin/caddy";
        in
        {
          Type = "notify";
          ExecStartPre = "${caddyBin} validate --config /etc/caddy/config.json";
          ExecStart = "${caddyBin} run --config /etc/caddy/config.json";
          ExecReload = "${caddyBin} reload --force --config /etc/caddy/config.json";
          DynamicUser = true;
          StateDirectory = "caddy";
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          Environment = [ "XDG_DATA_HOME=%S" ];
          Restart = "always";
          EnvironmentFile = lib.mkIf cfg.public config.vaultix.secrets.caddy.path;
          RestartSec = 1;
        };
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "network-online.target"
      ];
      requires = [ "network-online.target" ];
      reloadTriggers = [ configfile ];
    };
  };
}
