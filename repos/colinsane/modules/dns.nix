# TODO: consider using this library for .zone file generation:
# - <https://github.com/kirelagin/dns.nix>
{ config, lib, pkgs, ... }:

with builtins;
let
  cfg = config.sane.dns;
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
  # proto: "INET", etc
  # rrtype: "TXT", "A", "CNAME", etc
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
  # format other .zone files to include into this one
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

  # (listOf ty) type which also accepts single-assignment of `ty`.
  # it's used to allow the user to write:
  #   CNAME."foo" = "bar";
  # as shorthand for
  #   CNAME."foo" = [ "bar" ];
  listOrUnit = with lib; ty: types.coercedTo ty (elem: [ elem ]) (types.listOf ty);
in
{
  options = {
    sane.dns = with lib; {
      zones = mkOption {
        description = ''
          declarative zone config.
          this doesn't feed into anything, rather, one should read `config.sane.dns.zones."foo".rendered`
          and do something with it.
        '';
        default = {};
        type = types.attrsOf (types.submodule ({ name, config, ... }: {
          options = {
            name = mkOption {
              type = types.nullOr types.str;
              description = "zone name. defaults to the attribute name in zones";
              default = name;
            };
            rendered = mkOption {
              type = types.str;
              description = "rendered .zone text for this zone (read-only)";
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
          };
          config = {
            rendered = genZone config;
          };
        }));
      };
    };
  };
}
