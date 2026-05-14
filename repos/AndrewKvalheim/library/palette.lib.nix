{ lib, pkgs }:

let
  inherit (builtins) add foldl' length mapAttrs zipAttrsWith;
  inherit (lib) mapAttrsRecursiveCond;
  inherit (import ./utilities.lib.nix { inherit lib; }) findLowest rgbToCssRgba rgbToSgr;
  inherit ((import ../nur.nix { inherit pkgs; }).lib) contrastRatio linearRgbToRgb oklchToCss oklchToLinearRgb rgbToHex;

  mix = c1: c2: zipAttrsWith (_: xs: (foldl' add 0 xs) / (length xs)) [ c1 c2 ];
  dark = c: c // { l = 0.35; c = if c.c == 0 then 0 else 0.060; };
  dim = c: c // { l = 0.50; c = if c.c == 0 then 0 else 0.150; };
  contrast = ratio: oklch:
    let
      reference = mkColor null oklch;
      sufficient = l:
        let candidate = mkColor null (oklch // { inherit l; }); in
        contrastRatio reference.linearRgb candidate.linearRgb >= ratio;
    in
    oklch // { l = findLowest sufficient 0.005 oklch.l 1; };
  contrast-minimum = contrast 3;

  spec = rec {
    # Standard
    black-true = { l = 0; c = 0; h = 0; };

    # Base Monokai
    black = { l = 0.178; c = 0.000; h = 0; };
    blue = { l = 0.83; c = 0.108; h = 212; };
    green = { l = 0.84; c = 0.204; h = 127; };
    orange = { l = 0.77; c = 0.168; h = 62; };
    purple = { l = 0.70; c = 0.181; h = 298; };
    red = { l = 0.64; c = 0.240; h = 7; };
    white = { l = 0.98; c = 0.000; h = 0; };
    yellow = { l = 0.88; c = 0.125; h = 103; };

    # Base extension
    platinum = white // { l = 0.90; };
    teal = mix green blue // { l = 0.780; };
    vermilion = mix red orange // { l = 0.687; };

    # Dim
    blue-dim = dim blue // { c = 0.087; };
    green-dim = dim green // { c = 0.128; };
    orange-dim = dim orange // { c = 0.115; };
    purple-dim = dim purple;
    red-dim = dim red;
    teal-dim = dim teal // { c = 0.100; };
    vermilion-dim = dim vermilion;
    white-dim = dim white;
    yellow-dim = dim yellow // { c = 0.105; };

    # Dark
    blue-dark = dark blue;
    purple-dark = dark purple;
    red-dark = dark red;
    teal-dark = dark teal;
    vermilion-dark = dark vermilion;
    vermilion-dark-contrast-minimum = contrast-minimum vermilion-dark;
    white-dark = dark white;
  };

  mkColor = name: oklch: rec {
    inherit name oklch;

    css = oklchToCss oklch;
    cssRgba = rgbToCssRgba rgb;
    hex = rgbToHex rgb;
    linearRgb = oklchToLinearRgb oklch;
    rgb = linearRgbToRgb linearRgb;
    sgr = rgbToSgr rgb;
  };

  pool = mapAttrs mkColor spec;
in
rec {
  colors = pool // {
    ansi = with pool; {
      black = black-true;
      red = red;
      green = teal;
      yellow = yellow;
      blue = purple;
      magenta = orange;
      cyan = blue;
      white = platinum;

      bright = {
        black = white-dim;
        red = red;
        green = teal;
        yellow = yellow;
        blue = purple;
        magenta = orange;
        cyan = blue;
        white = white;
      };
    };
  };

  cssRgba = mapAttrsRecursiveCond (a: ! a ? oklch) (_: c: c.cssRgba) colors;

  hex = mapAttrsRecursiveCond (a: ! a ? oklch) (_: c: c.hex) colors;

  rgb = mapAttrsRecursiveCond (a: ! a ? oklch) (_: c: c.rgb) colors;
}
