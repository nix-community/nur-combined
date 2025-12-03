{ ... }:
let
  inherit (builtins) stringLength substring;
in
{
  # aka startsWith but hopefully clear from the name what order the arguments go
  isPrefixOf =
    prefix: s:
    let
      prefixl = stringLength prefix;
      sl = stringLength s;
    in
    (sl >= prefixl) && (substring 0 prefixl s) == prefix;
  isSuffixOf =
    suffix: s:
    let
      suffixl = stringLength suffix;
      sl = stringLength s;
      suffixStartIdx = sl - suffixl - 1;
      testSuffix = substring suffixStartIdx (-1) s;
    in
    (sl >= suffixl) && testSuffix == suffix;
}
