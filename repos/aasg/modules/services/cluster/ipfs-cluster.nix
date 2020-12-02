{ config, lib, pkgs, ... }:
with lib;
let
  settingsToEnv =
    let
      settingToNVP = prefix: name: value:
        let
          envName = toUpper "${prefix}_${name}";
        in
        if builtins.isAttrs value then
          settingsToNVP envName value
        else if builtins.isList value then
          nameValuePair envName (concatStringsSep "," value)
        else
          nameValuePair envName (toString value);
      settingsToNVP = prefix: settings:
        flatten (mapAttrsToList (settingToNVP prefix) settings);
    in
    settings: builtins.listToAttrs (settingsToNVP "cluster" settings);

  cfg = config.services.ipfs-cluster;

  # Is the cluster secret file in a home directory?
  secretInHome = cfg.secretFile != null && (
    hasPrefix "/root" cfg.secretFile || hasPrefix "/home" cfg.secretFile
  );
in
{
  options = {
    services.ipfs-cluster = {
      enable = mkEnableOption "IPFS Cluster daemon";

      package = mkOption {
        type = types.package;
        default = pkgs.ipfs-cluster;
        defaultText = "pkgs.ipfs-cluster";
        description = "ipfs-cluster package to use.";
      };

      user = mkOption {
        type = types.str;
        default = "ipfs";
        description = "User under which the IPFS Cluster daemon runs";
      };

      group = mkOption {
        type = types.str;
        default = "ipfs";
        description = "Group under which the IPFS Cluster daemon runs";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/ipfs-cluster";
        description = "Directory where cluster management data lives.";
      };

      secretFile = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "File containing the cluster secret. If none is given, a secret is generated during cluster creation.";
      };

      consensus = mkOption {
        type = types.enum [ "crdt" "raft" ];
        description = "Consensus component utilized by the cluster. This option has no effect on already existing clusters.";
      };

      bootstrapPeers = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = "List of peers to bootstrap the node with. This option has no effect on already existing clusters.";
      };

      settings = mkOption {
        type = types.attrs;
        default = { };
        description = "Additional IPFS Cluster settings. These follow the names for configuration environment variables, not for the service.json file.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.ipfs-cluster = {
      description = "IPFS Cluster daemon";
      after = [ "network-online.target" "ipfs.service" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        IPFS_CLUSTER_PATH = cfg.dataDir;
      } // settingsToEnv cfg.settings;
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-abnormal";
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        NoNewPrivileges = true;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = if secretInHome then "read-only" else true;
        ProtectSystem = "full";
        ReadWriteDirectories = cfg.dataDir;
        TimeoutStopSec = "5s";
      };
      preStart = ''
        ${optionalString (cfg.secretFile != null) ''
          read -r CLUSTER_SECRET <${cfg.secretFile}
        ''}
        if [[ ! -f ${cfg.dataDir}/service.json ]]; then
          ${cfg.package}/bin/ipfs-cluster-service init \
            --consensus ${cfg.consensus} \
            ${optionalString (cfg.bootstrapPeers != [ ]) "--peers ${concatStringsSep "," cfg.bootstrapPeers}"}
        fi
      '';
      script = ''
        ${optionalString (cfg.secretFile != null) ''
          read -r CLUSTER_SECRET <${cfg.secretFile}
        ''}
        exec ${cfg.package}/bin/ipfs-cluster-service daemon
      '';
    };
  };
}
