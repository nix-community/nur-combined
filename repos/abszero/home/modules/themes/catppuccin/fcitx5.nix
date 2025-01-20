{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.generators) toINIWithGlobalSection mkKeyValueDefault mkValueStringDefault;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.fcitx5.enable =
    mkExternalEnableOption config "catppuccin fcitx5 theme. Complementary to catppuccin/nix";

  # We don't enable catppuccin.fcitx.enable because we use the NixOS module
  config = mkIf cfg.fcitx5.enable {
    abszero.themes.catppuccin = {
      enable = true;
      fonts.enable = true;
    };
    xdg.configFile."fcitx5/conf/classicui.conf".text =
      toINIWithGlobalSection
        {
          # Capitalize boolean values
          mkKeyValue = mkKeyValueDefault {
            mkValueString =
              v:
              if v == true then
                "True"
              else if v == false then
                "False"
              else
                mkValueStringDefault { } v;
          } "=";
        }
        {
          globalSection = {
            Theme = "catppuccin-${
              if cfg.useSystemPolarity then cfg.lightFlavor else ctpCfg.flavor
            }-${ctpCfg.accent}";
            DarkTheme = "catppuccin-${cfg.darkFlavor}-${ctpCfg.accent}";
            UseDarkTheme = cfg.useSystemPolarity;
            "Vertical Candidate List" = true;
            Font = "Noto Sans 14";
            MenuFont = "Open Sans 14";
            TrayFont = "Open Sans 14";
            TrayOutlineColor = "#ffffff00";
            TrayTextColor = "#000000";
            PreferTextIcon = true;
          };
        };
  };
}
