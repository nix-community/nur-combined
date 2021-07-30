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
    "--insidevercolor=${c}"
    "--ringvercolor=${v}"
    "--insidewrongcolor=${c}"
    "--ringwrongcolor=${w}"
    "--insidecolor=${b}"
    "--ringcolor=${d}"
    "--linecolor=${b}"
    "--separatorcolor=${d}"
    "--verifcolor=${t}"
    "--wrongcolor=${t}"
    "--timecolor=${t}"
    "--datecolor=${t}"
    "--layoutcolor=${t}"
    "--keyhlcolor=${w}"
    "--bshlcolor=${w}"
    "--clock"
    "--indicator"
    "--timestr='%%H:%%M:%%S'"
    "--datestr='%%A %%B %%e'"
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
