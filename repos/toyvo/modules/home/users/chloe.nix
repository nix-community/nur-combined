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
  imports = [ ../catppuccin.nix ];

  options.nixcfg.users.chloe.enable = lib.mkEnableOption "Enable chloe profile";

  config = lib.mkIf cfg.users.chloe.enable {
    catppuccin = {
      flavor = "latte";
      accent = "pink";
    };
    home.packages =
      with pkgs;
      lib.optionals config.nixcfg.gui.enable [
        spotify
        discord
      ];
    services.easyeffects.enable = pkgs.stdenv.isLinux && cfg.gui.enable;
  };
}
