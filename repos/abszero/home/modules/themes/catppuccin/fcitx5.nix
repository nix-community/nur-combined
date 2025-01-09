{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.fcitx5.enable =
    mkExternalEnableOption config "catppuccin fcitx5 theme. Complementary to catppuccin/nix";

  config = mkIf cfg.fcitx5.enable {
    abszero.themes.catppuccin = {
      enable = true;
      fonts.enable = true;
    };
    catppuccin.fcitx5.enable = true;
    xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      Vertical Candidate List=True
      Font="Noto Sans 14"
      MenuFont="Open Sans 14"
      TrayFont="Open Sans 14"
      TrayOutlineColor=#ffffff00
      TrayTextColor=#000000
      PreferTextIcon=True
    '';
  };
}
