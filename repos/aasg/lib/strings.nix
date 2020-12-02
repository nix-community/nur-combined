{ lib, aasgLib, ... }:
let
  inherit (builtins) add foldl' head match stringLength substring;
  inherit (lib.lists) imap0 reverseList;
  inherit (lib.strings) hasInfix stringToCharacters toUpper;
  inherit (lib.trivial) pipe;
  inherit (aasgLib.lists) indexOf;
  inherit (aasgLib.math) pow;
in
rec {
  /*
   * Return the given string with its first character made uppercase.
   */
  capitalize = str: "${toUpper (substring 0 1 str)}${substring 1 (stringLength str) str}";

  /* parseHex :: string -> number | null
   *
   * Try to parse a number from a base-16 string.  If parsing fails,
   * null is returned.
   */
  parseHex = s:
    let
      hexChars = stringToCharacters "0123456789ABCDEF";
      sLen = stringLength s;
      parsed = pipe s [
        toUpper
        stringToCharacters
        reverseList
        (imap0 (i: c: (indexOf c hexChars) * (pow 16 i)))
        (foldl' add 0)
      ];
    in
    assert (match "[[:xdigit:]]*" s) != null;
    if sLen > 16 then null
    else if ! (sLen == 16 -> hasInfix (substring 0 1 s) "01234567") then null
    else parsed;
}
