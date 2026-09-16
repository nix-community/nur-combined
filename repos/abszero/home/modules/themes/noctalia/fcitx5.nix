{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.generators) toINIWithGlobalSection mkKeyValueDefault mkValueStringDefault;
  cfg = config.abszero.themes.noctalia.fcitx5;
in

{
  imports = [ ./fonts.nix ];

  options.abszero.themes.noctalia.fcitx5.enable = mkEnableOption "noctalia fcitx5 theme";

  config = mkIf cfg.enable {
    abszero.themes.noctalia.fonts.enable = true;
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
            Theme = "noctalia";
            "Vertical Candidate List" = true;
            Font = "Maple Mono NF CN 14";
            MenuFont = "Maple Mono NF CN 14";
            TrayFont = "Maple Mono NF CN 14";
            TrayOutlineColor = "#ffffff00";
            TrayTextColor = "#000000";
            PreferTextIcon = true;
          };
        };
  };
}
