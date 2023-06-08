{ config, lib, pkgs, ... }:

# TODO: consider using this library for .zone file generation:
# - <https://github.com/kirelagin/dns.nix>

with lib;
let
  cfg = config.sane.services.trust-dns;
  toml = pkgs.formats.toml { };

  configFile = toml.generate "trust-dns.toml" {
    listen_addrs_ipv4 = cfg.listenAddrsIPv4;
    zones = attrValues (
      mapAttrs (zname: zcfg: rec {
        zone = if zcfg.name == null then zname else zcfg.name;
        zone_type = "Primary";
        file = zcfg.file;
      }) cfg.zones
    );
  };
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
      listenAddrsIPv4 = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "array of ipv4 addresses on which to listen for DNS queries";
      };
      quiet = mkOption {
        type = types.bool;
        default = false;
      };
      zonedir = mkOption {
        type = types.nullOr types.str;
        default = "/";
        description = ''
          where the `file` option in zones.* is relative to.
        '';
      };
      # reference <nixpkgs:nixos/modules/services/web-servers/nginx/vhost-options.nix>
      zones = mkOption {
        type = types.attrsOf (types.submodule ({ config, name, ... }: {
          options = {
            name = mkOption {
              type = types.nullOr types.str;
              description = "zone name. defaults to the attribute name in zones";
              default = name;
            };
            text = mkOption {
              type = types.nullOr types.lines;
              default = null;
            };
            file = mkOption {
              type = types.nullOr (types.either types.path types.str);
              description = ''
                path to a .zone file.
                if omitted, will be generated from the `text` option.
              '';
            };
          };

          config = {
            file = lib.mkIf (config.text != null) (pkgs.writeText "${config.name}.zone" config.text);
          };
        }));
        default = {};
        description = "Declarative zone config";
      };
    };
  };

  config = mkIf cfg.enable {
    sane.ports.ports."53" = {
      protocol = [ "udp" "tcp" ];
      visibleTo.lan = true;
      visibleTo.wan = true;
      description = "colin-dns-hosting";
    };

    systemd.services.trust-dns = {
      description = "trust-dns DNS server";
      serviceConfig = {
        ExecStart =
          let
            flags = lib.optional cfg.quiet "-q" ++
              lib.optionals (cfg.zonedir != null) [ "--zonedir" cfg.zonedir ];
            flagsStr = builtins.concatStringsSep " " flags;
          in ''
            ${cfg.package}/bin/named \
              --config ${configFile} \
              ${flagsStr}
          '';
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "10s";
        # TODO: hardening (like, don't run as root!)
      };
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
