{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.catppuccin-home;
in
{
  options.nixcfg.catppuccin-home.enable = lib.mkEnableOption "Catppuccin theme configuration";

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = lib.mkDefault "frappe";
      accent = lib.mkDefault "red";
    };
  };
}
