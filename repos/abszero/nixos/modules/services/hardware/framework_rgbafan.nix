{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (builtins) concatStringsSep;
  inherit (lib)
    types
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    getExe
    ;
  cfg = config.abszero.services.hardware.framework_rgbafan;
  package = cfg.package.override { inherit (cfg) nLeds; };
in

{
  options.abszero.services.hardware.framework_rgbafan = {
    enable = mkEnableOption "simple tool to animate the fan on Framework Desktop";
    package = mkPackageOption pkgs "framework_rgbafan" { };
    mode = mkOption {
      type = types.enum [
        "static"
        "sequence"
        "random"
        "randominput"
        "quadspin"
        "fullspin"
        "smoothspin"
        "rainbowspin"
        "mpd"
      ];
      default = "static";
    };
    nLeds = mkOption {
      type = types.int;
      default = 8;
    };
    extraFlags = mkOption {
      type = with types; listOf singleLineStr;
      default = [ ];
    };
  };

  config.systemd.services.framework_rgbafan = mkIf cfg.enable {
    description = "Run the Framework RGBA fan tool";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${getExe package} ${cfg.mode} ${concatStringsSep " " cfg.extraFlags}";
      Restart = "on-failure";
      RestartSec = 5;
      RemainAfterExit = true;
    };
  };
}
