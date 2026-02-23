{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.userPresets;
  homePath = if pkgs.stdenv.isDarwin then "/Users" else "/home";
  enableGui = config.profiles.gui.enable;
in
{
  options.userPresets = {
    chloe = {
      enable = lib.mkEnableOption "chloe user";
      name = lib.mkOption {
        type = lib.types.str;
        default = "chloe";
      };
    };
  };

  config = {
    users = {
      users = {
        ${cfg.chloe.name} = lib.mkIf cfg.chloe.enable (
          lib.mkMerge [
            {
              name = cfg.chloe.name;
              description = "Chloe Diekvoss";
              home = "${homePath}/${cfg.chloe.name}";
              shell = pkgs.fish;
            }
            (lib.mkIf pkgs.stdenv.isLinux {
              isNormalUser = true;
              extraGroups = [
                "networkmanager"
                cfg.chloe.name
              ];
              initialHashedPassword = "$y$j9T$3qj7b7.lXJ2wiK29g9njQ1$Dn.dhmjQvPSkmdtHbA.2qEDl3eUnMeaawAW84X0/5i0";
            })
          ]
        );
      };
      groups.${cfg.chloe.name} = lib.mkIf pkgs.stdenv.isLinux { };
    };
    home-manager.users.${cfg.chloe.name} = lib.mkIf cfg.chloe.enable {
      home.username = cfg.chloe.name;
      home.homeDirectory = "${homePath}/${cfg.chloe.name}";
      profiles = {
        chloe.enable = true;
        defaults.enable = true;
        gui.enable = enableGui;
      };
    };
  };
}
