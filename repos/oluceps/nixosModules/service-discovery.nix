{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.realm.serviceDiscovery;
  dnsLabel = "[a-z0-9]([a-z0-9-]*[a-z0-9])?";
  validLabel = name: builtins.stringLength name <= 63 && builtins.match dnsLabel name != null;
  ipv6 = lib.types.strMatching "[0-9a-fA-F:]+";
  publication = lib.types.submodule (
    { name, ... }:
    {
      options = {
        unit = lib.mkOption {
          type = lib.types.strMatching ".+\\.(service|socket)";
          default = "${name}.service";
          description = "Unit implementing this ingress; used for configuration validation only.";
        };
        address = lib.mkOption {
          type = ipv6;
          default = cfg.address;
          defaultText = lib.literalExpression "config.realm.serviceDiscovery.address";
          description = "IPv6 address of the ingress.";
        };
        serverID = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Expected SPIFFE server identity from the declarative publisher.";
        };
        allowedIDs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Caller identities enforced by this endpoint.";
        };
        transport = lib.mkOption {
          type = lib.types.enum [
            "spiffe-tls"
            "plain"
          ];
          default = "spiffe-tls";
        };
        port = lib.mkOption {
          type = lib.types.nullOr lib.types.port;
          default = null;
          description = "Ingress port for SRV records; null publishes only AAAA records.";
        };
      };
    }
  );
  unitEnabled =
    unit:
    if lib.hasSuffix ".service" unit then
      config.systemd.services.${lib.removeSuffix ".service" unit}.enable or false
    else
      config.systemd.sockets.${lib.removeSuffix ".socket" unit}.enable or false;
  records = lib.unique (
    lib.mapAttrsToList (host: address: "${host}.node IN AAAA ${address}") cfg.nodes
    ++ lib.concatLists (
      lib.mapAttrsToList (
        host: services:
        lib.concatLists (
          lib.mapAttrsToList (
            name: service:
            let
              target = "${name}.${host}.svc";
            in
            [
              "${name}.svc IN AAAA ${service.address}"
              "${target} IN AAAA ${service.address}"
            ]
            ++ lib.optional (
              service.port != null
            ) "${name}.svc IN SRV 0 1 ${toString service.port} ${target}.${cfg.domain}."
          ) services
        )
      ) cfg.catalog
    )
  );
  # Immutable zones are loaded with a new Corefile on every deployment. No
  # zone transfers or runtime updates depend on an increasing SOA serial.
  zoneText = ''
    $ORIGIN ${cfg.domain}.
    $TTL 5
    @ IN SOA ns.${cfg.domain}. hostmaster.${cfg.domain}. 1 3600 600 86400 5
    @ IN NS ns.${cfg.domain}.
    ns IN A 127.0.0.1
    ns IN AAAA ::1
    ${lib.concatStringsSep "\n" records}
  '';
  zoneFile = pkgs.writeText "mesh.zone" cfg.zoneText;
in
{
  options.realm.serviceDiscovery = {
    enable = lib.mkEnableOption "local CoreDNS service discovery from declarative ingress records";
    address = lib.mkOption {
      type = ipv6;
      description = "Default IPv6 ingress address on this node.";
    };
    domain = lib.mkOption {
      type = lib.types.strMatching "${dnsLabel}(\\.${dnsLabel})+";
      default = "mesh.nyaw.xyz";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8600;
      description = "Local CoreDNS listener port on 127.0.0.1, for UDP and TCP.";
    };
    nodes = lib.mkOption {
      type = lib.types.attrsOf ipv6;
      default = {
        ${config.networking.hostName} = cfg.address;
      };
      description = "Cluster node IPv6 addresses, keyed by hostname.";
    };
    publish = lib.mkOption {
      type = lib.types.attrsOf publication;
      default = { };
      description = "Ingress endpoints declared by this node's service modules.";
    };
    catalog = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf publication);
      default = {
        ${config.networking.hostName} = cfg.publish;
      };
      description = "Cluster-wide ingress declarations, keyed by hostname and service name.";
    };
    zoneText = lib.mkOption {
      type = lib.types.lines;
      readOnly = true;
      internal = true;
      default = zoneText;
      description = "Generated authoritative zone; contains no runtime health state.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      lib.mapAttrsToList (name: service: {
        assertion = unitEnabled service.unit;
        message = "realm.serviceDiscovery.publish.${name}: ${service.unit} must be declared and enabled.";
      }) cfg.publish
      ++ lib.mapAttrsToList (host: _: {
        assertion = validLabel host;
        message = "realm.serviceDiscovery.nodes.${host}: hostname must be a lowercase DNS label.";
      }) cfg.nodes
      ++ lib.concatLists (
        lib.mapAttrsToList (
          host: services:
          [
            {
              assertion = validLabel host;
              message = "realm.serviceDiscovery.catalog.${host}: hostname must be a lowercase DNS label.";
            }
          ]
          ++ lib.mapAttrsToList (name: _: {
            assertion = validLabel name;
            message = "realm.serviceDiscovery.catalog.${host}.${name}: service name must be a lowercase DNS label.";
          }) services
        ) cfg.catalog
      );
    environment.etc."coredns/mesh.zone".source = zoneFile;
    services.coredns = {
      enable = true;
      config = ''
        ${cfg.domain}:${toString cfg.port} {
          bind 127.0.0.1
          file ${zoneFile} ${cfg.domain} {
            reload 0
          }
          errors
        }
      '';
    };
    systemd.services.coredns.serviceConfig = {
      # This listener uses an unprivileged loopback port.
      AmbientCapabilities = lib.mkForce [ ];
      CapabilityBoundingSet = lib.mkForce [ ];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
  };
}
