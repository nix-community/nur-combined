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

  options.nixcfg.users.briar.enable = lib.mkEnableOption "Enable briar profile";

  config = lib.mkIf cfg.users.briar.enable {
    catppuccin = {
      flavor = "latte";
      accent = "pink";
    };
    services.easyeffects.enable = pkgs.stdenv.isLinux && cfg.gui.enable;
  };
}
