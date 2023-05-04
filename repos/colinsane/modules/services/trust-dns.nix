{ config, lib, pkgs, ... }:

# TODO: consider using this library for .zone file generation:
# - <https://github.com/kirelagin/dns.nix>

with lib;
let
  cfg = config.sane.services.trust-dns;
  toml = pkgs.formats.toml { };
  recordFormatters = {
    # quote rules for zone files:
    # - any character may be encoded by `\DDD`, where `DDD` represents its ascii value in base 8.
    # - any non-digit `X` may be encoded by `\X`.
    # - stated in: <https://www.ietf.org/rfc/rfc1035.txt>: 5.1 Format
    # - visible in <trust-dns:crates/proto/src/serialize/txt/zone_lex.rs:escape_seq>
    # for us, we can just replace `\` => `\\ and `"` -> `\"`
    TXT = value: "\"" + (lib.escape [ "\\" "\"" ] value) + "\"";
  };
  fmtRecord = proto: rrtype: name: value:
    let
      formatter = recordFormatters."${rrtype}" or lib.id;
    in
      "${name}\t${proto}\t${rrtype}\t${formatter value}";
  fmtRecordList = proto: rrtype: name: values: concatStringsSep
    "\n"
    (map (fmtRecord proto rrtype name) values)
  ;
  fmtRecordAttrs = proto: rrtype: rrAttrs:
    concatStringsSep
      "\n"
      (
        attrValues (
          mapAttrs
            (name: fmtRecordList proto rrtype name)
            rrAttrs
        )
      );
  fmtIncludes = paths: concatStringsSep
    "\n"
    (map (path: "$INCLUDE ${path}") paths);

  genZone = zcfg: ''
    $TTL ${toString zcfg.TTL}
    ${fmtRecordAttrs "IN" "SOA" zcfg.inet.SOA}
    ${fmtRecordAttrs "IN" "A" zcfg.inet.A}
    ${fmtRecordAttrs "IN" "CNAME" zcfg.inet.CNAME}
    ${fmtRecordAttrs "IN" "MX" zcfg.inet.MX}
    ${fmtRecordAttrs "IN" "NS" zcfg.inet.NS}
    ${fmtRecordAttrs "IN" "SRV" zcfg.inet.SRV}
    ${fmtRecordAttrs "IN" "TXT" zcfg.inet.TXT}
    ${fmtIncludes zcfg.include}
    ${zcfg.extraConfig}
  '';

  configFile = toml.generate "trust-dns.toml" {
    listen_addrs_ipv4 = cfg.listenAddrsIPv4;
    zones = attrValues (
      mapAttrs (zname: zcfg: rec {
        zone = if zcfg.name == null then zname else zcfg.name;
        zone_type = "Primary";
        file = if zcfg.file == null then
          pkgs.writeText "${zone}.zone" (genZone zcfg)
        else
          zcfg.file;
      }) cfg.zones
    );
  };

  # (listOf ty) type which also accepts single-assignment of `ty`.
  # it's used to allow the user to write:
  #   CNAME."foo" = "bar";
  # as shorthand for
  #   CNAME."foo" = [ "bar" ];
  listOrUnit = ty: types.coercedTo ty (elem: [ elem ]) (types.listOf ty);
in
{
  options = {
    sane.services.trust-dns = {
      enable = mkOption {
        default = false;
        type = types.bool;
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
      # reference <nixpkgs:nixos/modules/services/web-servers/nginx/vhost-options.nix>
      zones = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            name = mkOption {
              type = types.nullOr types.str;
              description = "zone name. defaults to the attribute name in zones";
              default = null;
            };
            TTL = mkOption {
              type = types.int;
              description = "default TTL";
              default = 3600;
            };
            include = mkOption {
              type = types.listOf types.str;
              description = "paths of other zone files to $INCLUDE into this one";
              default = [];
            };
            extraConfig = mkOption {
              type = types.lines;
              description = "extra lines to append to the zone file";
              default = "";
            };
            inet = {
              SOA = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "Start of Authority record(s)";
                default = {};
              };
              A = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "IPv4 address record(s)";
                default = {};
              };
              CNAME = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "canonical name record(s)";
                default = {};
              };
              MX = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "mail exchanger record(s)";
                default = {};
              };
              NS = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "name server record(s)";
                default = {};
              };
              SRV = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "service record(s)";
                default = {};
              };
              TXT = mkOption {
                type = types.attrsOf (listOrUnit types.str);
                description = "text record(s)";
                default = {};
              };
            };

            file = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "instead of using the generated zone file, use the specified path";
            };
          };
        });
        default = {};
        description = "Declarative zone config";
      };

      generatedZones = mkOption {
        type = types.attrsOf types.str;
        description = "generated zone text for each zone";
      };
    };
  };

  config = mkIf cfg.enable {
    sane.services.trust-dns.generatedZones = mapAttrs (zone: zcfg: genZone zcfg) cfg.zones;
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    systemd.services.trust-dns = {
      description = "trust-dns DNS server";
      serviceConfig = {
        ExecStart =
          let
            flags = lib.optionalString cfg.quiet "-q";
          in ''
            ${pkgs.trust-dns}/bin/named \
              --config ${configFile} \
              --zonedir / ${flags}
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
