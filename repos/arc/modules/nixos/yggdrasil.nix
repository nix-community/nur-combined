{ pkgs, config, options, lib, ... }: with lib; let
  cfg = config.services.yggdrasil;
  opt = options.services.yggdrasil;
  isPath = lib.types.path.check;
  runtimeDir = "/run/${config.services.yggdrasil.serviceConfig.RuntimeDirectory or "yggdrasil"}";
  configFile = pkgs.writeText "yggdrasil.conf" (builtins.toJSON cfg.extraConfig);
  arc = import ../../canon.nix { inherit pkgs; };
  yggdrasil-address = pkgs.yggdrasil-address or arc.packages.yggdrasil-address;
  address = yggdrasil-address.importWithPublicKey cfg.publicKey;
  jsonType = with types; oneOf [ int str bool (listOf jsonType) (attrsOf jsonType) ];
in {
  options.services.yggdrasil = {
    peers = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    interfacePeers = mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    listen = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    adminListen = mkOption {
      type = types.nullOr types.path;
      default = runtimeDir + "/yggdrasil.sock";
    };

    multicastInterfaces = mkOption {
      type = types.listOf types.attrs;
      default = singleton {
        Regex = ".*";
        Beacon = true;
        Listen = true;
        Port = 0;
        Priority = 0;
      };
    };

    allowedPublicKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    address = mkOption {
      type = types.str;
    };

    publicKey = mkOption {
      type = types.str;
    };

    privateKey = mkOption {
      type = types.either types.str types.path;
    };

    linkLocalTcpPort = mkOption {
      type = types.port;
      default = 0;
    };

    ifName = mkOption {
      type = types.either (types.enum [ "auto" "none" ]) types.str;
      default = "auto";
    };

    ifMtu = mkOption {
      type = types.int;
      default = 65535;
    };

    sessionFirewall = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      allowFromDirect = mkOption {
        type = types.bool;
        default = true;
      };

      allowFromRemote = mkOption {
        type = types.bool;
        default = true;
      };

      alwaysAllowOutbound = mkOption {
        type = types.bool;
        default = true;
      };

      whitelistEncryptionPublicKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      blacklistEncryptionPublicKeys = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };

    tunnelRouting = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      ipv6RemoteSubnets = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };

      ipv6LocalSubnets = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      ipv4RemoteSubnets = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };

      ipv4LocalSubnets = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
    };

    switchOptions = {
      maxTotalQueueSize = mkOption {
        type = types.int;
        default = 4194304;
      };
    };

    nodeInfoPrivacy = mkOption {
      type = types.bool;
      default = false;
    };

    nodeInfo = mkOption {
      type = jsonType;
      default = { };
    };

    extraConfig = mkOption {
      type = jsonType;
      default = { };
    };
  };

  config = {
    systemd.services.yggdrasil = mkIf cfg.enable {
      preStart = let
        privateKey = key: o: c: optionalString (o.isDefined && isPath c) ''
          printf '{ "${key}": "%s" }' "$(cat ${toString c})"
        '';
      in mkOverride 90 ''
        {
          ${optionalString (cfg.configFile != null) "cat ${cfg.configFile}"}
          cat ${configFile}
          ${privateKey "PrivateKey" opt.privateKey cfg.privateKey}
          ${optionalString cfg.persistentKeys "cat /var/lib/yggdrasil/keys.json"}
        } | ${pkgs.jq}/bin/jq -s add > ${runtimeDir}/yggdrasil.conf
      '';
      serviceConfig.BindReadOnlyPaths = let
        privateKey = o: c: optional (o.isDefined && isPath c) (toString c);
      in [ "${configFile}" ]
      ++ privateKey opt.privateKey cfg.privateKey;
    };
    networking.firewall.allowedTCPPorts = mkIf (cfg.enable && cfg.openMulticastPort) [ cfg.linkLocalTcpPort ];
    services.yggdrasil = {
      address = mkIf opt.publicKey.isDefined (mkOptionDefault address);
      openMulticastPort = mkIf (cfg.linkLocalTcpPort != 0) (mkDefault true);
      extraConfig = mkMerge [ (cfg.settings or cfg.config) {
        Peers = mkIf (cfg.peers != [ ]) (mkOptionDefault cfg.peers);
        InterfacePeers = mkIf (cfg.interfacePeers != [ ]) (mkOptionDefault cfg.interfacePeers);
        Listen = mkIf (cfg.listen != [ ]) (mkOptionDefault cfg.listen);
        AdminListen = mkOptionDefault (if cfg.adminListen == null then "none" else "unix://${cfg.adminListen}");
        MulticastInterfaces = mkIf (cfg.multicastInterfaces != [ ]) (mkOptionDefault (
          if versionOlder cfg.package.version "0.4" then map (i: i.Regex) cfg.multicastInterfaces
          else cfg.multicastInterfaces
        ));
        AllowedPublicKeys = mkIf (cfg.allowedPublicKeys != [ ]) (mkOptionDefault cfg.allowedPublicKeys);
        PublicKey = mkIf (opt.publicKey.isDefined) (mkOptionDefault cfg.publicKey);
        PrivateKey = mkIf (opt.privateKey.isDefined && !isPath cfg.privateKey) (mkOptionDefault cfg.privateKey);
        LinkLocalTCPPort = mkOptionDefault cfg.linkLocalTcpPort;
        IfName = mkOptionDefault cfg.ifName;
        IfMTU = mkOptionDefault cfg.ifMtu;
        SessionFirewall = with cfg.sessionFirewall; mkOptionDefault {
          Enable = enable;
          AllowFromDirect = allowFromDirect;
          AllowFromRemote = allowFromRemote;
          AlwaysAllowOutbound = alwaysAllowOutbound;
          WhitelistEncryptionPublicKeys = whitelistEncryptionPublicKeys;
          BlacklistEncryptionPublicKeys = blacklistEncryptionPublicKeys;
        };
        TunnelRouting = with cfg.tunnelRouting; mkIf (versionOlder cfg.package.version "0.4") (mkOptionDefault {
          Enable = enable;
          IPv6RemoteSubnets = ipv6RemoteSubnets;
          IPv6LocalSubnets = ipv6LocalSubnets;
          IPv4RemoteSubnets = ipv4RemoteSubnets;
          IPv4LocalSubnets = ipv4LocalSubnets;
        });
        SwitchOptions = mkOptionDefault {
          MaxTotalQueueSize = cfg.switchOptions.maxTotalQueueSize;
        };
        NodeInfoPrivacy = mkOptionDefault cfg.nodeInfoPrivacy;
        NodeInfo = mkIf (cfg.nodeInfo != { }) (mkOptionDefault cfg.nodeInfo);
      } ];
    };
  };
}
