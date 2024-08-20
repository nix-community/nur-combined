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
        default = pkgs.callPackage ../../vvmd.nix {};
        description = "The package to use for vvmd.";
      };
    };

    config = mkIf cfg.enable {

      home.packages = [ cfg.package (pkgs.callPackage ../../vvmplayer.nix {}) ];

      systemd.user.services."vvmd" = {
        Unit = {
          Description = "lower level daemon that retrieves Visual Voicemail";
          After = [ "ModemManager.service" ];
        };
        Service = {
          ExecStart = [
            ""
            "${pkgs.vvmd}/bin/vvmd"
          ];
          Restart = "always";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };

    };
}

