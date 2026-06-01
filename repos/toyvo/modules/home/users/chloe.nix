{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg;
in
{
  options.nixcfg.users.chloe.enable = lib.mkEnableOption "Enable chloe profile";

  config = lib.mkIf cfg.users.chloe.enable {
    home.packages =
      with pkgs;
      lib.optionals config.nixcfg.gui.enable [
        spotify
        discord
      ];
    catppuccin = {
      flavor = "latte";
      accent = "pink";
    };
  };
}
