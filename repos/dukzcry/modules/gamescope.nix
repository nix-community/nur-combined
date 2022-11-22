{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.gamescope;
  gamescope = pkgs.nur.repos.dukzcry.gamescope;
in {
  options.programs.gamescope = {
    enable = mkEnableOption "SteamOS session compositing window manager";
  };

  config = mkMerge [

   (mkIf cfg.enable {
      environment.systemPackages = [ gamescope ];
      security.wrappers.gamescope = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_nice+p";
        source = "${gamescope}/bin/gamescope";
      };
   })
  ];

}
