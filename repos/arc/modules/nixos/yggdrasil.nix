{ pkgs, config, options, lib, ... }: with lib; let
  cfg = config.services.yggdrasil;
  opt = options.services.yggdrasil;
  isPath = lib.types.path.check;
  runtimeDir = "/run/${config.services.yggdrasil.serviceConfig.RuntimeDirectory or "yggdrasil"}";
  configFile = pkgs.writeText "yggdrasil.conf" (builtins.toJSON cfg.extraConfig);
  arc = import ../../canon.nix { inherit pkgs; };
  yggdrasil-address = (pkgs.yggdrasil-address or arc.build.yggdrasil-address).override (
    optionalAttrs (pkgs.yggdrasil != cfg.package) { yggdrasil = cfg.package; }
  );
  address = (yggdrasil-address cfg.encryptionPublicKey).address;
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
      type = types.listOf types.str;
      default = [ ".*" ];
    };

    allowedEncryptionPublicKeys = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    address = mkOption {
      type = types.str;
    };

    encryptionPublicKey = mkOption {
      type = types.str;
    };

    encryptionPrivateKey = mkOption {
      type = types.either types.str types.path;
    };

    signingPublicKey = mkOption {
      type = types.str;
    };

    signingPrivateKey = mkOption {
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
          ${privateKey "EncryptionPrivateKey" opt.encryptionPrivateKey cfg.encryptionPrivateKey}
          ${privateKey "SigningPrivateKey" opt.signingPrivateKey cfg.signingPrivateKey}
          ${optionalString cfg.persistentKeys "cat /var/lib/yggdrasil/keys.json"}
        } | ${pkgs.jq}/bin/jq -s add > ${runtimeDir}/yggdrasil.conf
      '';
      serviceConfig.BindReadOnlyPaths = let
        privateKey = o: c: optional (o.isDefined && isPath c) (toString c);
      in [ "${configFile}" ]
      ++ privateKey opt.encryptionPrivateKey cfg.encryptionPrivateKey
      ++ privateKey opt.signingPrivateKey cfg.signingPrivateKey;
    };
    networking.firewall.allowedTCPPorts = mkIf (cfg.enable && cfg.openMulticastPort) [ cfg.linkLocalTcpPort ];
    services.yggdrasil = {
      address = mkIf opt.encryptionPublicKey.isDefined (mkOptionDefault address);
      openMulticastPort = mkIf (cfg.linkLocalTcpPort != 0) (mkDefault true);
      extraConfig = mkMerge [ cfg.config {
        Peers = mkIf (cfg.peers != [ ]) (mkOptionDefault cfg.peers);
        InterfacePeers = mkIf (cfg.interfacePeers != [ ]) (mkOptionDefault cfg.interfacePeers);
        Listen = mkIf (cfg.listen != [ ]) (mkOptionDefault cfg.listen);
        AdminListen = mkOptionDefault (if cfg.adminListen == null then "none" else "unix://${cfg.adminListen}");
        MulticastInterfaces = mkIf (cfg.multicastInterfaces != [ ]) (mkOptionDefault cfg.multicastInterfaces);
        AllowedEncryptionPublicKeys = mkIf (cfg.allowedEncryptionPublicKeys != [ ]) (mkOptionDefault cfg.allowedEncryptionPublicKeys);
        EncryptionPublicKey = mkIf (opt.encryptionPublicKey.isDefined) (mkOptionDefault cfg.encryptionPublicKey);
        EncryptionPrivateKey = mkIf (opt.encryptionPrivateKey.isDefined && !isPath cfg.encryptionPrivateKey) (mkOptionDefault cfg.encryptionPrivateKey);
        SigningPublicKey = mkIf (opt.signingPublicKey.isDefined) (mkOptionDefault cfg.signingPublicKey);
        SigningPrivateKey = mkIf (opt.signingPrivateKey.isDefined && !isPath cfg.signingPrivateKey) (mkOptionDefault cfg.signingPrivateKey);
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
