{ lib }:

let
  inherit (builtins) add all attrValues floor mapAttrs split stringLength;
  inherit (lib) concatLines fixedWidthNumber fold isList max removeSuffix splitString throwIf throwIfNot toHexString;
  inherit (lib.strings) replicate;
  inherit (import <nix-math> { inherit lib; }) cos pi polynomial pow sin;

  # Taylor series approximation of pow(x, 1/2.4) pending NixOS/nix#10387
  pow124 = x: polynomial (x - 1) [
    ( 1.000000000) 0.416667000 (-0.121528000) 0.064139700 (-0.041423500) 0.029686900
    (-0.022677500) 0.018088000 (-0.014884900) 0.012541900 (-0.010765100) 0.009378720
    (-0.008271510) 0.007370120 (-0.006624340) 0.005998710 (-0.005467570) 0.005011940
    (-0.004617480) 0.004273200 (-0.003970510) 0.003702660 (-0.003464230) 0.003250850
    (-0.003058960) 0.002885620 (-0.002728390) 0.002585240 (-0.002454440) 0.002334530
    (-0.002224290) 0.002122650 (-0.002028670) 0.001941580 (-0.001860690) 0.001785370
    (-0.001715110) 0.001649450 (-0.001587950) 0.001530270 (-0.001476070) 0.001425070
    (-0.001377000) 0.001331640 (-0.001288760) 0.001248190 (-0.001209750) 0.001173290
    (-0.001138660) 0.001105740 (-0.001074410) 0.001044560 (-0.001016110) 0.000988945
    (-0.000963001) 0.000938196 (-0.000914462) 0.000891734 (-0.000869953) 0.000849064
    (-0.000829017) 0.000809764 (-0.000791261) 0.000773468 (-0.000756347) 0.000739863
    (-0.000723982) 0.000708674 (-0.000693910) 0.000679663 (-0.000665908) 0.000652621
    (-0.000639780) 0.000627364 (-0.000615354) 0.000603730 (-0.000592477) 0.000581576
    (-0.000571013) 0.000560774 (-0.000550843) 0.000541209 (-0.000531859) 0.000522781
    (-0.000513964) 0.000505398 (-0.000497073) 0.000488979 (-0.000481107) 0.000473449
    (-0.000465997) 0.000458742 (-0.000451678) 0.000444798 (-0.000438094) 0.000431561
    (-0.000425193) 0.000418983 (-0.000412926) 0.000407017 (-0.000401251) 0.000395623
    (-0.000390128) 0.000384762 (-0.000379521) 0.000374401 (-0.000369397) 0.000364506
    (-0.000359725) 0.000355050 (-0.000350477) 0.000346004 (-0.000341627) 0.000337344
    (-0.000333152) 0.000329048 (-0.000325030) 0.000321094 (-0.000317239) 0.000313462
    (-0.000309762) 0.000306135 (-0.000302580) 0.000299095 (-0.000295678) 0.000292327
    (-0.000289040) 0.000285816 (-0.000282653) 0.000279549 (-0.000276503) 0.000273512
    (-0.000270577) 0.000267695 (-0.000264865) 0.000262085 (-0.000259355) 0.000256673
    (-0.000254038) 0.000251449 (-0.000248905) 0.000246404 (-0.000243946) 0.000241529
    (-0.000239153) 0.000236816 (-0.000234518) 0.000232258 (-0.000230035) 0.000227848
    (-0.000225696) 0.000223579 (-0.000221495) 0.000219444 (-0.000217425) 0.000215438
    (-0.000213482) 0.000211555 (-0.000209659) 0.000207790 (-0.000205951) 0.000204138
    (-0.000202353) 0.000200595 (-0.000198862) 0.000197154 (-0.000195472) 0.000193814
  ];
in
rec {
  # Adapted from https://www.w3.org/WAI/WCAG22/Techniques/general/G18
  contrastRatio = linearRgb1: linearRgb2:
    let
      linearRgbToRelativeLuminance = rgb: with rgb; 0.2126 * r + 0.7152 * g + 0.0722 * b;
      flare = 0.05;
      ratio = light: dark: (light + flare) / (dark + flare);

      l1 = linearRgbToRelativeLuminance linearRgb1;
      l2 = linearRgbToRelativeLuminance linearRgb2;
    in
    if l1 < l2 then ratio l2 l1 else ratio l1 l2;

  findHighest = accept: resolution: low: high:
    if high - low < resolution then
      throwIfNot (accept low) "Lower bound ${toString low} fails acceptance test" low
    else
      let half = low + (high - low) * 0.5; in
      if accept half then findHighest accept resolution half high
      else findHighest accept resolution low half;

  findLowest = accept: resolution: low: high:
    if high - low < resolution then
      throwIfNot (accept high) "Upper bound ${toString high} fails acceptance test" high
    else
      let half = low + (high - low) * 0.5; in
      if accept half then findLowest accept resolution low half
      else findLowest accept resolution half high;

  frame = color: text:
    let
      lines = splitString "\n" (removeSuffix "\n" text);
      pad = printablePad (fold max 0 (map printableLength lines));
    in
    concatLines ([
      (color "┌───${pad "─" ""}───┐")
      (color "│   ${pad " " ""}   │")
    ] ++ map (l: "${color "│"}   ${pad " " l}   ${color "│"}") lines ++ [
      (color "│   ${pad " " ""}   │")
      (color "└───${pad "─" ""}───┘")
    ]);

  # Adapted from https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
  linearRgbToRgb = rgb:
    mapAttrs (_: u: if u > 0.0031308 then 1.055 * (pow124 u) - 0.055 else 12.92 * u) rgb;

  oklchToCss = { l, c, h }: "oklch(${toString l} ${toString c} ${toString h})";

  oklchToLinearRgb = target:
    let
      convert = { l, c, h }:
        let
          # Adapted from https://drafts.csswg.org/css-color-4/#color-conversion-code
          a = c * cos (h * pi / 180);
          b = c * sin (h * pi / 180);

          # Adapted from https://bottosson.github.io/posts/oklab/#converting-from-linear-srgb-to-oklab
          long = pow (l + 0.3963377774 * a + 0.2158037573 * b) 3;
          medium = pow (l - 0.1055613458 * a - 0.0638541728 * b) 3;
          short = pow (l - 0.0894841775 * a - 1.2914855480 * b) 3;
          rgb = {
            r = 4.0767416621 * long - 3.3077115913 * medium + 0.2309699292 * short;
            g = -1.2684380046 * long + 2.6097574011 * medium - 0.3413193965 * short;
            b = -0.0041960863 * long - 0.7034186147 * medium + 1.7076147010 * short;
          };
        in
        if all (u: 0 <= u && u <= 1) (attrValues rgb) then rgb else null;

      result = convert target;
      inGamut = c: convert (target // { inherit c; }) != null;
      clamped = target // { c = findHighest inGamut 0.0000005 0 0.37; };
    in
    throwIf (result == null)
      "Not representable in sRGB\n   Target: ${oklchToCss target}\n  Clamped: ${oklchToCss clamped}"
      result;

  printableLength = text: fold add 0 (map (v: if isList v then 0 else stringLength v) (split "\\[[^m]*m" text));

  printablePad = width: placeholder: text: text + replicate (width - printableLength text) placeholder;

  rgbToAnsi = rgb: with mapAttrs (_: v: toString (round (v * 255))) rgb; "38;2;${r};${g};${b}";

  rgbToHex = { r, g, b }:
    let f = x: fixedWidthNumber 2 (toHexString (round (x * 255)));
    in "#${f r}${f g}${f b}";

  round = x: floor (x + 0.5);
}
