{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) concatStringsSep length;
  inherit (lib)
    types
    mkPackageOption
    mkOption
    mkIf
    singleton
    getExe
    ;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.services.hardware.framework_rgbafan;
  package = cfg.package.override { inherit (cfg) nLeds; };
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.services.hardware.framework_rgbafan = {
    enable = mkExternalEnableOption config "simple tool to animate the fan on Framework Desktop";
    package = mkPackageOption pkgs "framework_rgbafan" { };
    mode = mkOption {
      type = types.enum [
        "solid"
        "blink"
        "smoothspin"
        "mpd"
      ];
      default = "solid";
    };
    colors = mkOption {
      type = with types; listOf singleLineStr;
    };
    nLeds = mkOption {
      type = lib.types.int;
      default = 8;
    };
  };

  config = mkIf cfg.enable {
    assertions = singleton {
      assertion = length cfg.colors <= cfg.nLeds;
      message = "number of colors must be smaller or equal to number of leds";
    };
    systemd.services.framework_rgbafan = {
      description = "Run the Framework RGBA fan tool";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe package} ${cfg.mode} ${concatStringsSep " " cfg.colors}";
        Restart = "on-failure";
        RestartSec = 5;
        RemainAfterExit = true;
      };
    };
  };
}
