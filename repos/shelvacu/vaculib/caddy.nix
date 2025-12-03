{ lib, ... }:
let
  inherit (lib) types;
  pat = "|[\n\t -~]*[]-~ -[\n\t]";
in
{
  types.caddyStr = let
    super = types.strMatching pat;
  in
  lib.mkOptionType {
    name = "caddyStr";
    description = ''string which is printable ascii and does not end with `\`, for caddyfiles'';
    descriptionClass = "noun";
    inherit (super) check merge;
  };

  caddyQuote =
    s:
    assert builtins.match pat s != null;
    ''"'' +
    (
      # yes, { needs two backslashes while " only needs one
      lib.replaceStrings [ ''"'' ''{'' ] [ ''\"'' ''\\{'' ] s
    ) +
    ''"'';
}
