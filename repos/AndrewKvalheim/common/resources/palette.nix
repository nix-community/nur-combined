{ lib, pkgs }:

let
  inherit (builtins) listToAttrs mapAttrs;
  inherit (lib) concatLines imap0 mapAttrsRecursiveCond mapAttrsToList nameValuePair;
  inherit (import ./lib.nix { inherit lib; }) findLowest rgbToAnsi;
  inherit ((import ../../nur.nix { inherit pkgs; }).lib) contrastRatio linearRgbToRgb oklchToCss oklchToLinearRgb rgbToHex sgr;

  dark = c: c // { l = 0.35; c = if c.c == 0 then 0 else 0.060; };
  dim = c: c // { l = 0.50; c = if c.c == 0 then 0 else 0.150; };
  contrast = ratio: oklch:
    let
      reference = mkColor oklch;
      sufficient = l:
        let candidate = mkColor (oklch // { inherit l; }); in
        contrastRatio reference.linearRgb candidate.linearRgb >= ratio;
    in
    oklch // { l = findLowest sufficient 0.005 oklch.l 1; };
  contrast-minimum = contrast 3;

  ansiNames = [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ];

  spec = rec {
    # Base Monokai
    black = { l = 0.22; c = 0.000; h = 0; };
    blue = { l = 0.83; c = 0.108; h = 212; };
    green = { l = 0.84; c = 0.204; h = 127; };
    orange = { l = 0.77; c = 0.168; h = 62; };
    purple = { l = 0.70; c = 0.181; h = 298; };
    red = { l = 0.64; c = 0.240; h = 7; };
    white = { l = 0.98; c = 0.000; h = 0; };
    yellow = { l = 0.88; c = 0.125; h = 103; };

    # Base extension
    platinum = { l = 0.90; c = 0.000; h = 0; };
    teal = { l = 0.81; c = 0.152; h = 171; };
    vermilion = { l = 0.68; c = 0.205; h = 36; };

    # Dim
    blue-dim = dim blue // { c = 0.087; };
    green-dim = dim green // { c = 0.128; };
    orange-dim = dim orange // { c = 0.115; };
    purple-dim = dim purple;
    red-dim = dim red;
    teal-dim = dim teal // { c = 0.097; };
    vermilion-dim = dim vermilion;
    white-dim = dim white;
    yellow-dim = dim yellow // { c = 0.105; };

    # Dark
    purple-dark = dark purple;
    red-dark = dark red;
    teal-dark = dark teal;
    vermilion-dark = dark vermilion;
    vermilion-dark-contrast-minimum = contrast-minimum vermilion-dark;
    white-dark = dark white;
  };

  mkColor = oklch: rec {
    inherit oklch;

    ansi = rgbToAnsi rgb;
    css = oklchToCss oklch;
    hex = rgbToHex rgb;
    linearRgb = oklchToLinearRgb oklch;
    rgb = linearRgbToRgb linearRgb;
  };

  colors = mapAttrs (_: mkColor) spec;
in
rec {
  ansi =
    let
      base = listToAttrs (imap0 (i: n: nameValuePair n { off = "39"; on = toString (30 + i); }) ansiNames);
      effect = off: on: mapAttrs (_: b: { off = "${off}${b.off}"; on = "${on};${b.on}"; }) base;
    in
    base // {
      bold = effect "22" "1";
      dim = effect "22" "2" // { italic = effect "22;23" "2;3"; };
      italic = effect "23" "3";
    };

  ansiFormat = mapAttrsRecursiveCond (a: ! a ? off) (_: { off, on }: sgr off on) ansi;

  hex = mapAttrs (_: c: c.hex) colors;

  report = concatLines (mapAttrsToList
    (name: { ansi, css, hex, ... }:
      "${sgr ansi.off ansi.on "██ ${name}"} ${ansiFormat.black "${css} ≈ ${hex}"}")
    colors
  );

  rgb = mapAttrs (_: c: c.rgb) colors;
}
