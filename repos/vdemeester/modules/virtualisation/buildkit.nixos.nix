{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.virtualisation.buildkitd;
in
{
  ###### interface

  options.virtualisation.buildkitd = {
    enable =
      mkOption {
        type = types.bool;
        default = false;
        description =
          ''
            This option enables buildkitd
          '';
      };

    listenOptions =
      mkOption {
        type = types.listOf types.str;
        default = [ "/run/buildkitd/buildkitd.sock" ];
        description =
          ''
            A list of unix and tcp buildkitd should listen to. The format follows
            ListenStream as described in systemd.socket(5).
          '';
      };

    package = mkOption {
      default = pkgs.buildkit;
      type = types.package;
      example = pkgs.buildkit;
      description = ''
        Buildkitd package to be used in the module
      '';
    };

    packages = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.runc pkgs.git ];
      description = "List of packages to be added to buildkitd service path";
    };

    extraOptions =
      mkOption {
        type = types.separatedString " ";
        default = "";
        description =
          ''
            The extra command-line options to pass to
            <command>buildkitd</command> daemon.
          '';
      };
  };

  ###### implementation

  config = mkIf cfg.enable {
    users.groups = [
      {
        name = "buildkit";
        gid = 350;
      }
    ];
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.buildkitd = {
      wants = [ "containerd.service" ];
      after = [ "containerd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = [
          ""
          ''
            ${cfg.package}/bin/buildkitd \
              ${cfg.extraOptions}
          ''
        ];
      };
      path = [ cfg.package ] ++ cfg.packages;
    };


    systemd.sockets.buildkitd = {
      description = "Buildkitd Socket for the API";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = cfg.listenOptions;
        SocketMode = "0660";
        SocketUser = "root";
        SocketGroup = "buildkit";
      };
    };

  };


}
