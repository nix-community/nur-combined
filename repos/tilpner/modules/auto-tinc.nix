{ config, pkgs, lib, ... }:

# Assumes node names are installation-unique

let
  inherit (builtins) substring match all;
  inherit (lib) take drop length stringToCharacters concatStrings intersperse optionalString;
  inherit (pkgs) runtimeShell;

  cleanHost = lib.replaceChars ["." "-"] ["_" "_"];
  currentHost = cleanHost config.networking.hostName;

  subnets = host: ''
    ${optionalString (notNull host.ipv4)
      "Subnet = ${host.ipv4}/32"}
    ${optionalString (notNull host.ipv6)
      "Subnet = ${host.ipv6}/128"}
  '';

  tincNameRegex = "[A-Za-z0-9_]+";
  validTincName = name: (match tincNameRegex name) != null;

  notNull = x: x != null;

  cfg = config.services.auto-tinc;
in with lib; {
  options.services.auto-tinc.networks = mkOption {
    default = {};
    type = with types; attrsOf (submodule (netArgs@{ name, config, ... }: {
      options = {
        entry = mkOption { type = listOf str; };
        trusted = mkOption { type = bool; default = false; };
        ipv4Prefix = mkOption { type = nullOr str; default = null; };
        ipv6Prefix = mkOption { type = nullOr str; default = "fd7f:8482:73b2::"; };
        hosts = mkOption {
          default = {};
          type = attrsOf (submodule (hostArgs@{ name, ... }: {
            options = {
              config = mkOption { type = str; default = ""; };
              ipv4Suffix = mkOption { type = nullOr str; default = null; };
              ipv6Suffix = mkOption { type = nullOr str; default = null; };
              ipv4 = mkOption {
                internal = true;
                type = nullOr str;
                default = if (all notNull [ netArgs.config.ipv4Prefix hostArgs.config.ipv4Suffix ])
                  then "${netArgs.config.ipv4Prefix}${hostArgs.config.ipv4Suffix}"
                  else null;
              };
              ipv6 = mkOption {
                internal = true;
                type = nullOr str;
                default = if (all notNull [ netArgs.config.ipv6Prefix hostArgs.config.ipv6Suffix ])
                  then "${netArgs.config.ipv6Prefix}${hostArgs.config.ipv6Suffix}"
                  else null;
              };
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
          ipv6sInNetwork = netName: net: filter notNull (mapAttrsToList (hostName: host: host.ipv6) net.hosts);
          ipv6s = concatLists (mapAttrsToList ipv6sInNetwork cfg.networks);
      in [
      { assertion = all validTincName netNames;
        message = "A network name doesn't match ${tincNameRegex}"; }
      { assertion = all validTincName hostNames;
        message = "A host name doesn't match ${tincNameRegex}"; }
      { assertion = all (n: stringLength "tinc.${n}" <= 16) netNames;
        message = "Interface names must be <= 16 chars"; }
      { assertion = length ipv6s == length (unique ipv6s);
        message = "There are duplicate IPv6 addresses"; }
    ];

    networking.firewall.trustedInterfaces =
      let f = name: net: if net.trusted then [ "tinc.${name}" ] else [];
      in  concatLists (mapAttrsToList f cfg.networks);


/*
    services.dnsmasq.enable = true;
    services.dnsmasq.extraConfig =
      let forNet = netName: net:
        let forHost = hostName: host:
          ''
            host-record=${hostName}.${netName},${optionalString (notNull host.ipv4) host.ipv4},${optionalString (notNull host.ipv6) host.ipv6}
            cname=*.${hostName}.${netName},${hostName}.${netName}
          '';
        in ''
          auth-server=${netName},tinc.${netName}
          auth-zone=${netName},127.0.0.0/24,tinc.${netName}

          ${concatStringsSep "\n" (mapAttrsToList forHost net.hosts)}
        '';
      in concatStringsSep "\n\n" (mapAttrsToList forNet cfg.networks);
*/

    services.tinc.networks =
      let forNet = netName: net: {
            ${netName} = {
              inherit (net) package;
              extraConfig = ''
                AddressFamily = any
              '' + (concatMapStringsSep "\n" (entry: "ConnectTo = ${entry}") net.entry);
              hosts = mapAttrs (hostName: host: host.config + (subnets host)) net.hosts;
            };
          };
      in  mkMerge (mapAttrsToList forNet cfg.networks);

    environment.etc =
      let ip = "${pkgs.iproute}/bin/ip";
          forNet = netName: net: {
            "tinc/${netName}/tinc-up" = {
              mode = "0755";
              text = ''
                #!${runtimeShell}
                ${ip} link set $INTERFACE up
                ${optionalString (notNull net.hosts.${currentHost}.ipv4)
                  "${ip} addr add ${net.hosts.${currentHost}.ipv4}/24 dev $INTERFACE"}
                ${optionalString (notNull net.hosts.${currentHost}.ipv6)
                  "${ip} addr add ${net.hosts.${currentHost}.ipv6}/64 dev $INTERFACE"}
              '';
            };

            "tinc/${netName}/tinc-down" = {
              mode = "0755";
              text = ''
                #!${runtimeShell}
                ${ip} link set $INTERFACE down
              '';
            };
          };
      in  mkMerge (mapAttrsToList forNet cfg.networks);

    lib.tinc =
      let forNet = netName: net: {
            garden = { inherit (net.hosts.${currentHost}) ipv4 ipv6; };
          };
      in  mkMerge (mapAttrsToList forNet cfg.networks);

    # Why does this module provide addresses in two different ways?
    # * /etc/hosts works even if the DNS server is offline
    # * A DNS server can be used on platforms where /etc/hosts can't be set (Android)
    # * A DNS server supports wildcard subdomains, which is useful for virtual hosts

    networking.hosts =
      let forNet = netName: net:
        let forHost = hostName: host:
              nameValuePair host.ipv4 "${hostName}.${netName}.tinc";
        in  mapAttrs' forHost (filterAttrs (_: host: notNull host.ipv4) net.hosts);
      in  zipAttrs (mapAttrsToList forNet cfg.networks);

    services.bind = mkIf (any (net: net.hostDNS) (attrValues cfg.networks)) {
      enable = true;

      listenOn = [ "127.0.0.1" ] ++
        (mapAttrsToList (netName: net: "${net.hosts.${currentHost}.ipv4}/32")
          (filterAttrs (netName: net: notNull net.hosts.${currentHost}.ipv4) cfg.networks));
      listenOnIpv6 = [ "::1" ] ++
        (mapAttrsToList (netName: net: "${net.hosts.${currentHost}.ipv6}/128")
          (filterAttrs (netName: net: notNull net.hosts.${currentHost}.ipv6) cfg.networks));

      cacheNetworks = flatten [
        "127.0.0.1/32"
        (mapAttrsToList
          (netName: net: mapAttrsToList (hostName: host:
            (optional (notNull host.ipv4) "${host.ipv4}/32") ++
            (optional (notNull host.ipv6) "${host.ipv6}/128"))
            net.hosts)
          (filterAttrs (netName: net: net.hostDNS) cfg.networks))
      ];

      zones =
        let forHost = hostName: host: ''
              ${optionalString (notNull host.ipv4) ''
                ${hostName} IN A ${host.ipv4}
                *.${hostName} IN A ${host.ipv4}
              ''}
              ${optionalString (notNull host.ipv6) ''
                ${hostName} IN AAAA ${host.ipv6}
                *.${hostName} IN AAAA ${host.ipv6}
              ''}
            '';
            forNet = netName: net: {
              name = netName;
              master = true;
              file = pkgs.writeText "${netName}.zone" ''
                $ORIGIN ${netName}.
                
                @ 3600 SOA ns1.tinc hostmaster.tinc (
                  2019011700
                  3600
                  3600
                  3600
                  3600
                )

                @ IN NS localhost.

                ${concatStringsSep "\n" (mapAttrsToList forHost net.hosts)}
              '';
            };
        in mapAttrsToList forNet cfg.networks;
    };
  };
}
