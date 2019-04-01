{ config, pkgs, lib, ... }:

# Assumes node names are installation-unique

let
  inherit (builtins) hashString substring match all;
  inherit (lib) take drop length stringToCharacters concatStrings intersperse;

  listChunks =
    size: ls: if length ls <= size
                then [ ls ]
                else [ (take size ls) ] ++ (listChunks size (drop size ls));

  nameToIpv6Suffix = name:
    let hash = hashString "sha256" name;
        chunks = listChunks 4 (stringToCharacters (substring 0 16 hash));
    in concatStrings (intersperse ":" (map concatStrings chunks));

  cleanHost = lib.replaceChars ["." "-"] ["_" "_"];
  currentHost = cleanHost config.networking.hostName;

  ipv6 = netName: net: hostName: "${net.ipv6Prefix}${nameToIpv6Suffix "${netName}/${hostName}${net.salt}"}";
  subnets = ipv6: ''
    Subnet = ${ipv6}/128
  '';

  tincNameRegex = "[A-Za-z0-9_]+";
  validTincName = name: (match tincNameRegex name) != null;

  cfg = config.services.auto-tinc;
in with lib; {
  options.services.auto-tinc.networks = mkOption {
    default = {};
    type = with types; attrsOf (submodule (netArgs@{ name, config, ... }: {
      options = {
        entry = mkOption { type = listOf string; };
        trusted = mkOption { type = bool; default = false; };
        ipv6Prefix = mkOption { type = string; default = "fd7f:8482:73b2::"; };
        salt = mkOption { type = string; default = ""; };
        hosts = mkOption {
          default = {};
          type = attrsOf (submodule (hostArgs@{ name, ... }: {
            options = {
              config = mkOption { type = string; default = ""; };
              ipv6 = mkOption {
                internal = true;
                type = string;
                default = ipv6 netArgs.name netArgs.config hostArgs.name; };
              };
          }));
        };
        package = mkOption { type = package; default = pkgs.tinc_pre; };
        hostDNS = mkEnableOption "Host DNS server for this network on this node";
      };
    }));
  };

  config = {
    assertions =
      let netNames = attrNames cfg.networks;
          hostNames = attrNames (zipAttrs (catAttrs "hosts" (attrValues cfg.networks)));
          ipv6sInNetwork = netName: net: mapAttrsToList (hostName: host: ipv6 netName net hostName) net.hosts;
          ipv6s = concatLists (mapAttrsToList ipv6sInNetwork cfg.networks);
      in [
      { assertion = all validTincName netNames;
        message = "A network name doesn't match ${tincNameRegex}"; }
      { assertion = all validTincName hostNames;
        message = "A host name doesn't match ${tincNameRegex}"; }
      { assertion = all (n: stringLength "tinc.${n}" <= 16) netNames;
        message = "Interface names must be <= 16 chars"; }
      { assertion = length ipv6s == length (unique ipv6s);
        message = "There are duplicate IPv6 addresses, try changing salts"; }
    ];

    networking.firewall.trustedInterfaces =
      let f = name: net: if net.trusted then [ "tinc.${name}" ] else [];
      in  concatLists (mapAttrsToList f cfg.networks);

    services.dnsmasq.enable = true;
    services.dnsmasq.extraConfig =
      let forNet = netName: net:
        let forHost = hostName: host:
          ''
            host-record=${hostName}.${netName},,${ipv6 netName net hostName}
            cname=*.${hostName}.${netName},${hostName}.${netName}
          '';
        in ''
          auth-server=${netName},tinc.${netName}
          auth-zone=${netName},127.0.0.0/24,tinc.${netName}

          ${concatStringsSep "\n" (mapAttrsToList forHost net.hosts)}
        '';
      in concatStringsSep "\n\n" (mapAttrsToList forNet cfg.networks);

    services.tinc.networks =
      let forNet = netName: net: {
            ${netName} = {
              inherit (net) package;
              extraConfig = concatMapStringsSep "\n" (entry: "ConnectTo = ${entry}") net.entry;
              hosts = mapAttrs (hostName: host: host.config + (subnets host.ipv6)) net.hosts;
            };
          };
      in  mkMerge (mapAttrsToList forNet cfg.networks);

    environment.etc =
      let ip = "${pkgs.iproute}/bin/ip";
          forNet = netName: net: {
            "tinc/${netName}/tinc-up" = {
              mode = "0755";
              text = ''
                #!${pkgs.stdenv.shell}
                ${ip} link set $INTERFACE up
                ${ip} addr add ${ipv6 netName net currentHost}/64 dev $INTERFACE
              '';
            };

            "tinc/${netName}/tinc-down" = {
              mode = "0755";
              text = ''
                #!${pkgs.stdenv.shell}
                ${ip} link set $INTERFACE down
              '';
            };
          };
      in  mkMerge (mapAttrsToList forNet cfg.networks);
  };
}
