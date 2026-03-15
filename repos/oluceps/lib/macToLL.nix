{ lib, ... }:
mac:
let
  # strip colons and convert to lowercase
  cleanMac = builtins.replaceStrings [ ":" ] [ "" ] (lib.toLower mac);

  # map for flipping the 7th bit (u/l bit) of the first byte
  # the 7th bit from the left corresponds to the 2nd bit from the right of the second hex character.
  invertMap = {
    "0" = "2";
    "1" = "3";
    "2" = "0";
    "3" = "1";
    "4" = "6";
    "5" = "7";
    "6" = "4";
    "7" = "5";
    "8" = "a";
    "9" = "b";
    "a" = "8";
    "b" = "9";
    "c" = "e";
    "d" = "f";
    "e" = "c";
    "f" = "d";
  };

  c1 = builtins.substring 0 1 cleanMac;
  c2 = builtins.substring 1 1 cleanMac;
  rest1 = builtins.substring 2 2 cleanMac;
  rest2 = builtins.substring 4 2 cleanMac;
  rest3 = builtins.substring 6 2 cleanMac;
  rest4 = builtins.substring 8 4 cleanMac;

  newC2 = invertMap.${c2} or (throw "invalid mac character: ${c2}");

  b1 = "${c1}${newC2}${rest1}";
  b2 = "${rest2}ff";
  b3 = "fe${rest3}";
  b4 = "${rest4}";
in
"fe80::${b1}:${b2}:${b3}:${b4}"
