{ config, lib, pkgs, ... }:

let
  cfg = config.programs.gpu-screen-recorder-ui;
in
{
  options.programs.gpu-screen-recorder-ui = {
    enable = lib.mkEnableOption (lib.mdDoc "Install a fullscreen overlay UI for GPU Screen Recorder in the style of ShadowPlay");

    systemd = {
      enable = lib.mkEnableOption (lib.mdDoc "Enable a user systemd service for gsr-ui autostart");

      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        example = "sway-session.target";
        description = lib.mdDoc "User systemd target to bind and start gsr-ui under.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gpu-screen-recorder-ui
      pkgs.gpu-screen-recorder-notification
      pkgs.gpu-screen-recorder
    ];

    systemd.user.services.gpu-screen-recorder-ui = lib.mkIf cfg.systemd.enable {
      Unit = {
        Description = "GPU Screen Recorder UI";
        PartOf = [ cfg.systemd.target ];
        After = [ cfg.systemd.target ];
        Wants = [ cfg.systemd.target ];
      };
      Service = {
        ExecStart = "${pkgs.gpu-screen-recorder-ui}/bin/gsr-ui";
        Restart = "on-failure";
        RestartSec = 3;
        Type = "simple";
      };
      Install = {
        WantedBy = [ cfg.systemd.target ];
      };
    };
  };
}
