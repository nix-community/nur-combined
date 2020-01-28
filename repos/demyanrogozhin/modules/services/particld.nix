{ lib, pkgs, config, ... }:

with lib;
let
  cfg = config.services.particld;
  pidFile = "${cfg.dataDir}/particld.pid";
  configFile = pkgs.writeText "particld.conf" ''
    ${optionalString cfg.testnet "testnet=1"}

    # Connection options
    ${optionalString (cfg.port != null) "port=${toString cfg.port}"}

    # Extra config options (from bitcoind nixos service)
    ${cfg.extraConfig}
  '';
  cmdlineOptions = concatMapStringsSep " " (arg: "'${arg}'") [
    "-conf=${cfg.configFile}"
    "-datadir=${cfg.dataDir}"
    "-pid=${pidFile}"
  ];
in {

  options.services.particld = {
    enable = mkEnableOption "Particl Node service";
    package = mkOption {
      type = types.package;
      default = pkgs.particl-daemon;
      defaultText = "pkgs.particl-daemon";
      description = "The Particl package to use";
    };
    configFile = mkOption {
      type = types.path;
      default = configFile;
      example = "/etc/particld.conf";
      description = "The configuration file path to supply Particl.";
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        par=16
        rpcthreads=16
        logips=1
      '';
      description =
        "Additional configurations to be appended to <filename>particld.conf</filename>.";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/particld";
      description = "The data directory for Particl.";
    };
    user = mkOption {
      type = types.str;
      default = "particl";
      description = "The user as which to run Particl.";
    };
    group = mkOption {
      type = types.str;
      default = cfg.user;
      description = "The group as which to run Particl.";
    };
    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description =
        "Override the default port on which to listen for connections.";
    };
    proxy = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Connect through SOCKS5 proxy";
    };
    testnet = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use the test chain.";
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    systemd.services.particl = {
      description = "Particl daemon";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/particld -daemon ${cmdlineOptions}";
        Type = "forking";
        Restart = "on-failure";

        ExecStop = "${cfg.package}/bin/particl-cli -conf=${configFile} stop";
        ExecStop = "${pkgs.coreutils}/bin/sleep 25";

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";

        TimeoutStopSec = "60s";
        TimeoutStartSec = "2s";
        StartLimitInterval = "120s";
        StartLimitBurst = "5";
        RestartSec = "2s";
      };
    };
    users.users.${cfg.user} = {
      name = cfg.user;
      group = cfg.group;
      description = "Particl Node user";
      home = cfg.dataDir;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = { name = cfg.group; };
  };
}
