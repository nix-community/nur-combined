# WIP: porting to the API described here:
# - <https://github.com/NixOS/nixpkgs/pull/205866>
# - TODO: hardening!
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.sane.services.trust-dns;
  toml = pkgs.formats.toml { };

  configFile = toml.generate "trust-dns.toml" (
    lib.filterAttrsRecursive (_: v: v != null) cfg.settings
  );
in
{
  options = {
    sane.services.trust-dns = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.trust-dns;
        description = ''
          trust-dns package to use.
          should provide bin/named, which will be invoked with --config x and --zonedir d and maybe -q.
        '';
      };
      quiet = mkOption {
        type = types.bool;
        default = false;
        description = ''
          log ERROR level messages only.
          if not specified, defaults to INFO level logging.
          mutually exclusive with the `debug` option.
        '';
      };
      debug = mkOption {
        type = types.bool;
        default = false;
        description = ''
          log DEBUG, INFO, WARN and ERROR messages.
          if not specified, defaults to INFO level logging.
          mutually exclusive with the `quiet` option.
        '';
      };
      settings = mkOption {
        type = types.submodule {
          freeformType = toml.type;
          options = {
            listen_addrs_ipv4 = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "array of ipv4 addresses on which to listen for DNS queries";
            };
            listen_addrs_ipv6 = mkOption {
              type = types.listOf types.str;
              default = [];
              description = "array of ipv6 addresses on which to listen for DNS queries";
            };
            listen_port = mkOption {
              type = types.port;
              default = 53;
              description = ''
                port to listen on (applies to all listen addresses).
              '';
            };
            directory = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                directory in which trust-dns will look for .zone files
                whenever zones aren't specified by absolute path.
                upstream defaults this to "/var/named".
              '';
            };
            zones = mkOption {
              description = "Declarative zone config";
              default = {};
              type = types.listOf (types.submodule ({ config, name, ... }: {
                options = {
                  zone = mkOption {
                    type = types.str;
                    description = ''
                      zone name, like "example.com", "localhost", or "0.0.127.in-addr.arpa".
                    '';
                  };
                  zone_type = mkOption {
                    type = types.enum [ "Primary" "Secondary" "Hint" "Forward" ];
                    default = "Primary";
                    description = ''
                      one of:
                      - "Primary" (the master, authority for the zone)
                      - "Secondary" (the slave, replicated from the primary)
                      - "Hint" (a cached zone with recursive resolver abilities)
                      - "Forward" (a cached zone where all requests are forwarded to another resolver)
                    '';
                  };
                  file = mkOption {
                    type = types.either types.path types.str;
                    description = ''
                      path to a .zone file.
                      if not a fully-qualified path, it will be interpreted relative to the `directory` option.
                      defaults to the value of `zone` suffixed with ".zone".
                    '';
                  };
                };
                config = {
                  file = lib.mkDefault "${config.zone}.zone";
                };
              }));
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.trust-dns = {
      description = "trust-dns DNS server";
      serviceConfig = {
        ExecStart =
        let
          flags = lib.optional cfg.debug "--debug"
            ++ lib.optional cfg.quiet "--quiet";
          flagsStr = builtins.concatStringsSep " " flags;
        in ''
          ${cfg.package}/bin/named --config ${configFile} ${flagsStr}
        '';
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "10s";
        # TODO: hardening (like, don't run as root!)
        # TODO: link to docs
      };
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
