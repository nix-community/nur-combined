{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vvmd;
in {
  #meta.maintainers = [ maintainers.mich-adams ];

  options.services.vvmd = {
    enable = mkEnableOption "vvmd";
    };

    config = mkIf cfg.enable {

      home.packages = [ (pkgs.callPackage ./vvmplayer.nix {}) (pkgs.callPackage ./vvmd.nix {}) ];

      systemd.user.services."vvmd" = {
        Unit = {
          Description = "lower level daemon that retrieves Visual Voicemail";
          After = [ "ModemManager.service" ];
        };
        Service = {
          ExecStart = [
            ""
            "${(pkgs.callPackage ./vvmd.nix {})}/bin/vvmd"
          ];
          Restart = "always";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };

    };
}

