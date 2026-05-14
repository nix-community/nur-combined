{ lib }:

let
  inherit (builtins) add all attrValues ceil concatLists elem elemAt filter foldl' getAttr hasAttr head isFunction isString length listToAttrs mapAttrs match split stringLength tail toJSON;
  inherit (lib) concatLines concatImapStringsSep concatMapStrings concatMapStringsSep escapeShellArg fixedWidthNumber flip fold id ifilter0 imap0 isList max min mod nameValuePair pipe range removeSuffix splitString stringToCharacters throwIf throwIfNot toCamelCase toHexString versionAtLeast versionOlder zipAttrsWith;
  inherit (lib.strings) replicate;
  inherit (import <nix-math> { inherit lib; }) cos pi pow round sin;

  asciiTable = import <nixpkgs/lib/ascii-table.nix>;
  isAscii = text: all (c: hasAttr c asciiTable) (stringToCharacters text);
  asciiStringLength = text: throwIfNot (isAscii text) "`builtins.stringLength` does not support Unicode text “${text}”" (stringLength text);
in
rec {
  ansiColorNames = [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ];

  bullet = t: concatImapStringsSep "\n" (i: l: "${if i == 1 then "- " else "  "}${l}") (splitString "\n" t);

  # Adapted from https://en.wikipedia.org/wiki/Clenshaw_algorithm#Special_case_for_Chebyshev_series
  chebyshev = coefficients: x:
    let
      a0 = head coefficients;
      recurrence = a: { b1, b2 }: { b1 = a + 2.0 * x * b1 - b2; b2 = b1; };
      inherit (fold recurrence ({ b1 = 0; b2 = 0; }) (tail coefficients)) b1 b2;
      b0 = 2.0 * x * b1 - b2;
    in
    0.5 * (a0 + b0 - b2);

  chebyshevWithDomain = beginning: end: coefficients: x:
    chebyshev coefficients (-1.0 + 2.0 * (x - beginning) / (end - beginning));

  columns = sep: items:
    let
      columnsCount = max 1 ((terminalWidth + sepWidth) / (columnWidth + sepWidth));
      columnWidth = fold max 0 (map printableLength items);
      fullRowsCount = itemsCount / columnsCount;
      itemsCount = length items;
      lastRowItemsCount = mod itemsCount columnsCount;
      rowsCount = ceil ((itemsCount * 1.0) / columnsCount);
      sepWidth = printableLength sep;
      terminalWidth = 100;

      mkCell = cellIndex:
        let
          columnIndex = mod cellIndex columnsCount;
          isLastCell = cellIndex == itemsCount - 1;
          isLastColumn = columnIndex == columnsCount - 1;
          item = elemAt items itemIndex;
          itemIndex = (min columnIndex lastRowItemsCount) * rowsCount
            + (max 0 (columnIndex - lastRowItemsCount)) * fullRowsCount
            + rowIndex;
          rowIndex = cellIndex / columnsCount;
        in
        if isLastCell then item else if isLastColumn then "${item}\n" else "${pad item}${sep}";
      pad = printablePad columnWidth " ";
    in
    concatMapStrings mkCell (range 0 (itemsCount - 1));

  compose = flip pipe;

  # Adapted from https://www.w3.org/WAI/WCAG22/Techniques/general/G18
  contrastRatio = linearRgb1: linearRgb2:
    let
      linearRgbToRelativeLuminance = { r, g, b }: 0.2126 * r + 0.7152 * g + 0.0722 * b;
      flare = 0.05;
      ratio = light: dark: (light + flare) / (dark + flare);

      l1 = linearRgbToRelativeLuminance linearRgb1;
      l2 = linearRgbToRelativeLuminance linearRgb2;
    in
    if l1 < l2 then ratio l2 l1 else ratio l1 l2;

  csi = final: params: "[${params}${final}";

  cull = limit: items: let n = ceil ((length items) * 1.0 / limit); in ifilter0 (i: _: mod i n == 0) items;

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

  indent = n: t: concatMapStringsSep "\n" (l: "${replicate n " "}${l}") (splitString "\n" t);

  # Adapted from https://bottosson.github.io/posts/colorwrong/#what-can-we-do%3F
  linearRgbToRgb = mapAttrs (_: u: if u > 0.0031308 then 1.055 * pow u (1 / 2.4) - 0.055 else 12.92 * u);

  lookup = flip getAttr;

  mkSgr = off: on: text: "${csi "m" on}${text}${csi "m" off}";

  ne = a: b: a != b;

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

  printableLength = text: fold add 0 (map (v: if isList v then 0 else asciiStringLength v) (split "\\[[^m]*m" text));

  printablePad = width: placeholder: text: text + replicate (max 0 (width - printableLength text)) placeholder;

  rgbToHex = { r, g, b }:
    let f = x: fixedWidthNumber 2 (toHexString (round (x * 255)));
    in "#${f r}${f g}${f b}";

  rgbToCssRgba = rgb: a: with mapAttrs (_: v: toString (round (v * 255))) rgb; "rgba(${r}, ${g}, ${b}, ${toString a})";

  rgbToSgr = rgb: with mapAttrs (_: v: toString (round (v * 255))) rgb; mkSgr "39" "38;2;${r};${g};${b}";

  sgr =
    let
      mkColors = f: b: listToAttrs (imap0 (i: n: nameValuePair (f n) { off = "39"; on = toString (b + i); }) ansiColorNames);

      f = p: f':
        if f' == null then p
        else if isFunction f' then let p' = f' null; in f { off = "${p'.off};${p.off}"; on = "${p.on};${p'.on}"; }
        else mkSgr p.off p.on f';
    in
    mapAttrs (_: f) (mkColors id 30 // mkColors (n: toCamelCase "bright-${n}") 90 // {
      bold = { off = "22"; on = "1"; };
      dim = { off = "22"; on = "2"; };
      doubleUnderline = { off = "24"; on = "21"; };
      inverse = { off = "27"; on = "7"; };
      italic = { off = "23"; on = "3"; };
      strike = { off = "29"; on = "9"; };
      underline = { off = "24"; on = "4"; };
    });

  tryEscapeShellArg = arg: if match "^\".*\"$" arg == null then escapeShellArg arg else arg;

  tryEscapeShellArgs = concatMapStringsSep " " tryEscapeShellArg;

  uniqueBy = f: xs: (foldl'
    (acc: x: let x' = f x; in if elem x' acc.xs' then acc else zipAttrsFlat [ acc { xs = [ x ]; xs' = [ x' ]; } ])
    { xs = [ ]; xs' = [ ]; }
    xs).xs;

  versionSatisfied = v: spec:
    let
      v' = if isString v then v else v.version;

      satisfied = expr:
        let parts = match "^([^[:alnum:]]+)?(.+)?$" expr; operator = head parts; reference = elemAt parts 1; in
        if operator == null then v' == reference
        else if operator == "∞" then true
        else if operator == "≠" then v' != reference
        else if operator == "<" then versionOlder v' reference
        else if operator == ">" then versionOlder reference v'
        else if operator == "≥" then versionAtLeast v' reference
        else throw "version operator not implemented: ${toJSON operator}";
    in
    all satisfied (filter isString (split ",[[:space:]]*" spec));

  versionsSatisfied = all (pr: let v = head pr; rs = elemAt pr 1; in versionSatisfied v rs);

  zipAttrsFlat = zipAttrsWith (_: concatLists);
}
