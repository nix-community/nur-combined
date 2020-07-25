{ config, lib, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;
  rgb = base: "#" + base.hex.rgb;

in {
  options.services.xscreensaver.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.services.xscreensaver.enableBase16Theme {
    services.xscreensaver.settings = {
      "Dialog.foreground" = mkDefault (rgb colors.base05);
      "Dialog.background" = mkDefault (rgb colors.base00);
      "Dialog.topShadowColor" = mkDefault (rgb colors.base02);
      "Dialog.bottomShadowColor" = mkDefault (rgb colors.base02);
      "Dialog.Button.foreground" = mkDefault (rgb colors.base05);
      "Dialog.Button.background" = mkDefault (rgb colors.base00);
      "Dialog.text.foreground" = mkDefault (rgb colors.base05);
      "Dialog.text.background" = mkDefault (rgb colors.base01);
      "Dialog.internalBorderWidth" = mkDefault 36;
      "Dialog.borderWidth" = mkDefault 0;
      "Dialog.shadowThickness" = mkDefault 2;
      "passwd.thermometer.foreground" = mkDefault (rgb colors.base08);
      "passwd.thermometer.background" = mkDefault (rgb colors.base00);
      "passwd.thermometer.width" = mkDefault 8;
    };
  };
}
