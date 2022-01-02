{ config, lib, pkgs, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;
  rgb = base: "#" + base.hex.rgb;
  rgba = base: alpha: rgb base + alpha;

  args = let
    b = rgb colors.base00;
    c = rgba colors.base05 "22";
    d = rgb colors.base0A;
    t = rgb colors.base05;
    w = rgb colors.base08;
    v = rgb colors.base0E;
  in [
    "--color=${b}"
    "--insidever-color=${c}"
    "--ringver-color=${v}"
    "--insidewrong-color=${c}"
    "--ringwrong-color=${w}"
    "--inside-color=${b}"
    "--ring-color=${d}"
    "--line-color=${b}"
    "--separator-color=${d}"
    "--verif-color=${t}"
    "--wrong-color=${t}"
    "--time-color=${t}"
    "--date-color=${t}"
    "--layout-color=${t}"
    "--keyhl-color=${w}"
    "--bshl-color=${w}"
    "--clock"
    "--indicator"
    "--time-str='%%H:%%M:%%S'"
    "--date-str='%%a %%b %%e'"
    "--keylayout 1"
  ];

in {
  options.services.screen-locker.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.services.screen-locker.enableBase16Theme {
    services.screen-locker = {
      lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color ${toString args}";
    };
  };
}
