{ config, lib, pkgs, ... }:
let
  cfg = config.services.g13d;
  g13d = pkgs.callPackage ../../pkgs/g13d {};

  config_file = pkgs.writeText "g13d.bind" cfg.config;
in
{
  options.services.g13d = {
    enable = lib.mkEnableOption "g13d";

    config = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Configuration for g13d

        See: https://github.com/ecraven/g13#commands
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ g13d ];

    # users.users.g13d = {
    #   description = "User for g13d";
    #   isSystemUser = true;
    #   group = "g13d";
    # };

    users.groups.g13d = {};

    systemd.services.g13d = {
      description = "Logitech G13 Daemon";
      after = [ "multi-user.target"];

      serviceConfig = {
        User = "root";
        Group = "root";
        Restart = "on-failure";

        Type = "simple";
        ExecStart = "${g13d}/bin/g13d --config ${config_file} --pipe_in /run/g13d/g13-0 --pipe_out /run/g13d/g13-0_out";
      };
    };

  };
}
