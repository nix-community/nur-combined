{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gamescope;
in {
  options.programs.gamescope = {
    enable = mkEnableOption "SteamOS session compositing window manager";
  };

  config = mkMerge [

   (mkIf cfg.enable {
      security.wrappers.gamescope = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_nice+p";
        source = "${pkgs.gamescope}/bin/gamescope";
      };
   })
  ];

}
