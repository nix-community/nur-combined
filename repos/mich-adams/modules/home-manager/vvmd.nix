{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vvmd;
  tomlFormat = pkgs.formats.toml { };
in {
  meta.maintainers = [ maintainers.mich-adams ];

  options = {
    services.vvmd = {
      enable = mkEnableOption "vvmd service";

    };

    config = mkIf serviceConfig.enable {
      assertions = [
        (lib.hm.assertions.assertPlatform "services.vvmd" pkgs
        lib.platforms.linux)
      ];

      home.packages = [ pkgs.vvmd pkgs.vvmplayer ];

      xdg.configFile."itd.toml" = lib.mkIf (serviceConfig.settings != { }) {
        source = tomlFormat.generate "itd.toml" serviceConfig.settings;
      };

      systemd.user = {
        services.vvmd = {
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
    };
  }

