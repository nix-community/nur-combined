{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ../base/foot.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.foot.enable =
    mkExternalEnableOption config "catppuccin foot theme. Complementary to catppuccin/nix";

  config = mkIf cfg.foot.enable {
    abszero.themes = {
      base.foot.enable = true;
      catppuccin = {
        enable = true;
        fonts.enable = true;
      };
    };
    catppuccin.foot.enable = true;
    programs.foot = {
      settings.main.font = "Iosevka Term Extended:size=13";
    };
  };
}
