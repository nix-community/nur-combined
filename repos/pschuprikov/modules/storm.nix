{ lib, config, pkgs, ... }:
with lib;
let 
  cfg = config.services.storm;
  generateConfig = pkgs.runCommand "storm-conf" {} (''
    mkdir -p $out
    cp --no-preserve=mode -R ${cfg.package}/conf/* $out
    cat <<EOF >$out/storm.yaml
    nimbus.thrift.port: ${toString cfg.nimbus.thriftPort}
    nimbus.seeds:
  '' + 
    lib.concatMapStringsSep "\n" (srv: " - \"${srv}\"") cfg.supervisor.nimbusSeeds + "\n" + ''
    storm.zookeeper.servers:
    '' +
    lib.concatMapStringsSep "\n" (srv: " - \"${srv}\"") cfg.zookeeperServers + "\n" + ''
    storm.local.dir: "/var/run/storm"
    storm.log.dir: "/var/log/storm"
    storm.log4j2.conf.dir: "$out/log4j2"
    ui.port: ${toString cfg.ui.port}
    topology.environment:
  '' + 
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: " ${name}: \"${value}\"") cfg.extraTopologyEnvironment) + "\n" + ''
    blobstore.dir: "/var/lib/storm/blobstore"
  '' + 
    lib.optionalString cfg.debug ''
    nimbus.childopts: "-Xmx1024m -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005"
  '' +
    lib.optionalString (cfg.hostname != null) ''
    storm.local.hostname: "${toString cfg.hostname}"
  '' +
  ''
    EOF
    sed -i -Ee 's/root level="info"/root level="${cfg.loglevel}"/' \
      $out/log4j2/cluster.xml
  '');
in {
  options.services.storm = {
    enable = mkEnableOption "Apache Storm";
    package = mkOption {
      type = types.package;
      description = "Storm package";
      default = pkgs.storm;
    };
    user = mkOption {
      type = types.str;
      description = "User running Apache Storm";
    };
    loglevel = mkOption {
      type = types.str;
      description = "Log level of the root logger";
      default = "info";
    };
    hostname = mkOption {
      type = types.nullOr types.str;
      description = "The hostname the supervisors/workers should report to nimbus";
      default = null;
    };
    debug = mkOption {
      type = types.bool;
      description = "Whether to enable debug jvm options";
      default = false;
    };
    zookeeperServers = mkOption {
      type = types.listOf types.str;
      description = "List of Zookeeper servers";
      default = [ "localhost" ];
    };
    nimbus = {
      enable = mkEnableOption "Apache Storm -- Nimbus";
      thriftPort = mkOption {
        type = types.int;
        description = "Nimbus thrift port";
        default = 6627;
      };
    };
    ui = {
      enable = mkEnableOption "Apache Storm -- UI";
      port = mkOption {
        type = types.int;
        description = "UI port";
        default = 8080;
      };
    };
    supervisor = {
      enable = mkEnableOption "Apache Storm -- Supervisor";
      nimbusSeeds = mkOption {
        type = types.listOf types.str;
        description = "Nimbus seeds";
        default = [ "localhost" ];
      };
    };
    extraTopologyEnvironment = mkOption {
      type = types.attrsOf types.str;
      description = "Environment variables for topology execution";
      default = {};
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.systemPackages = [ cfg.package ];
    }
    (mkIf cfg.nimbus.enable {
      systemd.services.storm-nimbus = {
        after = [ "network.target" ];
        description = "Storm nimbus";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "${cfg.user}";
          LogsDirectory = "storm";
          RuntimeDirectory = "storm/nimbus";
          StateDirectory = "storm";
          Restart = "on-failure";
          ExecStart = ''
            ${cfg.package}/bin/storm nimbus --config ${generateConfig}/storm.yaml
          '';
        };
      };
    })
    (mkIf cfg.supervisor.enable {
      systemd.services.storm-supervisor = {
        after = [ "network.target" ];
        description = "Storm Supervisor";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "${cfg.user}";
          LogsDirectory = "storm";
          RuntimeDirectory = "storm";
          StateDirectory = "storm";
          Restart = "on-failure";
          ExecStart = ''
            ${cfg.package}/bin/storm supervisor --config ${generateConfig}/storm.yaml
          '';
        };
      };
    })
    (mkIf cfg.ui.enable {
      systemd.services.storm-ui = {
        after = [ "network.target" ];
        description = "Storm UI";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          User = "${cfg.user}";
          LogsDirectory = "storm";
          RuntimeDirectory = "storm/ui";
          ExecStart = ''
            ${cfg.package}/bin/storm ui --config ${generateConfig}/storm.yaml
          '';
        };
      };
    })
  ]);
}
