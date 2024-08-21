{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vvmd;
in {
  #meta.maintainers = [ maintainers.mich-adams ];

  options.services.vvmd = {
    enable = mkEnableOption "vvmd";

      package = mkOption {
        type = types.package;
        default = pkgs.nur.repos.mich-adams.vvmd;
        defaultText = "pkgs.nur.repos.mich-adams.vvmd";
        description = "The package to use for vvmd.";
      };
    };

    config = mkIf cfg.enable {

      home.packages = [ cfg.package pkgs.nur.repos.mich-adams.vvmplayer ];

      systemd.user.services."vvmd" = {
        Unit = {
          Description = "lower level daemon that retrieves Visual Voicemail";
          After = [ "ModemManager.service" ];
        };
        Service = {
          ExecStart = [
            ""
            "${cfg.package}/bin/vvmd"
          ];
          Restart = "always";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };

    };
}

