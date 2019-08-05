{ pkgs, config, lib, ... }: with lib; let
  cfg = config.services.yggdrasil;
  isPath = lib.types.path.check;
  configFile = builtins.toFile "yggdrasil.conf" (builtins.toJSON configData);
  configData = (convertConfig cfg) // cfg.extraConfig;
  convertConfig = cfg: {
    Peers = cfg.peers;
    InterfacePeers = cfg.interfacePeers;
    Listen = cfg.listen;
    AdminListen = if cfg.adminListen == null then "none" else "unix://${cfg.adminListen}";
    MulticastInterfaces = cfg.multicastInterfaces;
    AllowedEncryptionPublicKeys = cfg.allowedEncryptionPublicKeys;
    EncryptionPublicKey = cfg.encryptionPublicKey;
    EncryptionPrivateKey = assert !isPath cfg.encryptionPrivateKey; cfg.encryptionPrivateKey;
    SigningPublicKey = cfg.signingPublicKey;
    SigningPrivateKey = assert !isPath cfg.signingPrivateKey; cfg.signingPrivateKey;
    LinkLocalTCPPort = cfg.linkLocalTcpPort;
    IfName = cfg.ifName;
    IfTAPMode = cfg.ifTapMode;
    IfMTU = cfg.ifMtu;
    SessionFirewall = with cfg.sessionFirewall; {
      Enable = enable;
      AllowFromDirect = allowFromDirect;
      AllowFromRemote = allowFromRemote;
      AlwaysAllowOutbound = alwaysAllowOutbound;
      WhitelistEncryptionPublicKeys = whitelistEncryptionPublicKeys;
      BlacklistEncryptionPublicKeys = blacklistEncryptionPublicKeys;
    };
    TunnelRouting = with cfg.tunnelRouting; {
      Enable = enable;
      IPv6Destinations = ipv6Destinations;
      IPv6Sources = ipv6Sources;
      IPv4Destinations = ipv4Destinations;
      IPv4Sources = ipv4Sources;
    };
    SwitchOptions.MaxTotalQueueSize = cfg.switchOptions.maxTotalQueueSize;
    NodeInfoPrivacy = cfg.nodeInfoPrivacy;
    NodeInfo = cfg.nodeInfo;
  };
in {
  options.services.yggdrasil = {
    enable = mkEnableOption "yggdrasil systemd service";

    group = mkOption {
      type = types.str;
      default = "yggdrasil";
      description = "Group account under which yggdrasil runs.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.yggdrasil;
      defaultText = "pkgs.yggdrasil";
    };

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
      default = "/run/yggdrasil.sock";
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

    ifTapMode = mkOption {
      type = types.bool;
      default = false;
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

      ipv6Destinations = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };

      ipv6Sources = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };

      ipv4Destinations = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };

      ipv4Sources = mkOption {
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
      type = types.attrs;
      default = { };
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    users.groups = mkIf (cfg.group == "yggdrasil") { yggdrasil = { }; };

    systemd.services.yggdrasil = {
      description = "yggdrasil network";
      wants = ["network.target"];
      after = ["network.target"];

      serviceConfig = {
        Group = cfg.group;
        ProtectHome = true;
        ProtectSystem = true;
        SyslogIdentifier = "yggdrasil";
        ExecStart = "${cfg.package}/bin/yggdrasil -useconffile ${configFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
      };

      wantedBy = ["multi-user.target"];
    };
  };
}
