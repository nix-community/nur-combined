{ config, lib, pkgs, ... }:
let
  cfg = config.virtualisation.mycontainerd;

  inherit (lib) mkOption types mkIf;
in
{
  options.virtualisation.mycontainerd = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        This option enables containerd, a daemon that manages linux containers.
      '';
    };

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Start containerd automatically.
      '';
    };

    package = mkOption {
      default = pkgs.containerd;
      type = types.package;
      example = pkgs.containerd;
      description = ''
        Containerd package to be used in the module
      '';
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.runc pkgs.cni pkgs.cni-plugins ];
      description = "List of packages to be added to containerd service path";
    };

    extraOptions = mkOption {
      type = types.separatedString " ";
      default = "";
      description =
        ''
          The extra command-line options to pass to
          <command>containerd</command> daemon.
        '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.packages = [ cfg.package ];

    systemd.services.containerd = {
      wantedBy = lib.optional cfg.autostart [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = [
          ""
          ''
            ${cfg.package}/bin/containerd \
            ${cfg.extraOptions}
          ''
        ];
      };
      path = [ cfg.package ] ++ cfg.extraPackages;
    };


    systemd.sockets.containerd = {
      description = "Containerd Socket for the API";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = "/run/containerd/containerd.sock";
        SocketMode = "0660";
        SocketUser = "root";
        SocketGroup = "root";
      };
    };

  };


}
