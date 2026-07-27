{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg;
in
{
  options.nixcfg.users.briar.enable = lib.mkEnableOption "Enable briar profile";

  config = lib.mkIf cfg.users.briar.enable {
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "latte";
      accent = "pink";
    };
    services.easyeffects.enable = pkgs.stdenv.isLinux && cfg.gui.enable;
  };
}
