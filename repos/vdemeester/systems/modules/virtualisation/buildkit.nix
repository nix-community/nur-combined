{ config, lib, pkgs, ... }:
let
  cfg = config.virtualisation.buildkitd;
  inherit (lib) mkOption mkIf;
  inherit (lib.types) attrsOf str nullOr path bool package listOf;

  configFile =
    if cfg.configFile == null then
      settingsFormat.generate "buildkitd.toml" cfg.settings
    else
      cfg.configFile;

  settingsFormat = pkgs.formats.toml { };
in
{
  options.virtualisation.buildkitd = {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''This option enables buildkitd'';
    };

    package = mkOption {
      default = pkgs.buildkit;
      type = package;
      example = pkgs.buildkit;
      description = ''
        Buildkitd package to be used in the module
      '';
    };

    packages = mkOption {
      type = listOf package;
      default = [ pkgs.runc pkgs.git ];
      description = "List of packages to be added to buildkitd service path";
    };

    configFile = lib.mkOption {
      default = null;
      description = ''
        Path to containerd config file.
        Setting this option will override any configuration applied by the settings option.
      '';
      type = nullOr path;
    };

    args = lib.mkOption {
      default = { };
      description = "extra args to append to the containerd cmdline";
      type = attrsOf str;
    };

    settings = lib.mkOption {
      type = settingsFormat.type;
      default = {
        grpc.address = [ "unix:///run/buildkit/buildkitd.sock" ];
      };
      description = ''
        Verbatim lines to add to containerd.toml
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups.buildkit.gid = 350;
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    virtualisation.buildkitd = {
      args = {
        group = "buildkit";
        config = toString configFile;
      };
      settings = {
        debug = false;
      };
    };

    systemd.services.buildkitd = {
      after = [ "network.target" "containerd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''${cfg.package}/bin/buildkitd ${lib.concatStringsSep " " (lib.cli.toGNUCommandLine {} cfg.args)}'';
        Delegate = "yes";
        KillMode = "process";
        Type = "notify";
        Restart = "always";
        RestartSec = "10";

        # "limits" defined below are adopted from upstream: https://github.com/containerd/containerd/blob/master/containerd.service
        LimitNPROC = "infinity";
        LimitCORE = "infinity";
        LimitNOFILE = "infinity";
        TasksMax = "infinity";
        OOMScoreAdjust = "-999";
      };
      path = [ cfg.package ] ++ cfg.packages;
    };

  };


}
