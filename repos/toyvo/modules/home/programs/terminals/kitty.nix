{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kitty;
in
{
  config = lib.mkIf cfg.enable {
    catppuccin.kitty = {
      enable = true;
      flavor = config.catppuccin.flavor;
    };
    programs.kitty = {
      font = {
        name = "MonaspiceNe Nerd Font Mono Regular";
        size = 14;
      };
      settings = {
        shell = "${lib.getExe pkgs.ion}";
      };
      extraConfig = ''
        font_features MonaspiceNeNFM-Regular +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08 +calt +dlig
      '';
    };
  };
}
