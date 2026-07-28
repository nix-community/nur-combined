{ lib, ... }:
let
  pat = "|[\n\t -~]*[]-~ -[\n\t]";
in
rec {
  types.caddyStr =
    let
      super = lib.types.strMatching pat;
    in
    lib.mkOptionType {
      name = "caddyStr";
      description = ''string which is printable ascii and does not end with `\`, for caddyfiles'';
      descriptionClass = "noun";
      inherit (super) check merge;
    };

  caddyQuote =
    s:
    let
      # yes, { needs two backslashes while " only needs one
      escaped = lib.replaceStrings [ ''"'' "{" ] [ ''\"'' ''\\{'' ] s;
    in
    lib.throwIf (
      (builtins.match pat s) == null
    ) ''vaculib.caddyQuote can only accept ascii strings that do not end with `\`'' ''"${escaped}"'';

  _tests.caddyQuote.simple =
    assert (caddyQuote ''hello " there{'') == ''"hello \" there\\{"'';
    true;
  _tests.caddyQuote.empty =
    assert (caddyQuote "") == ''""'';
    true;
  _tests.caddyQuote.endingBackslash =
    assert !(builtins.tryEval (caddyQuote ''foo\'')).success;
    true;
}
