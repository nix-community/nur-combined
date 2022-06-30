{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.sunshine;
  sunshine = pkgs.nur.repos.dukzcry.sunshine;
in {
  options.programs.sunshine = {
    enable = mkEnableOption "Sunshine headless server";
    user = mkOption {
      type = types.str;
    };
    games = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkMerge [

   (mkIf cfg.enable {
      environment.systemPackages = [ sunshine ];
      hardware.uinput.enable = true;
      users.extraUsers.${cfg.user} = {
        extraGroups = [ "uinput" "video" ];
        packages = cfg.games;
      };
      security.wrappers.sunshine = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+p";
        source = "${sunshine}/bin/sunshine";
      };
   })
  ];

}
