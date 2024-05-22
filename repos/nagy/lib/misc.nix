{ lib, ... }:

{

  mapNumToString = lib.elemAt (lib.splitString "" "abcdefghijklmnopqrstuvwxyz");

  mapStringToNum =
    str:
    let
      thelist = lib.imap0 (i: v: { inherit i v; }) (lib.splitString "" "abcdefghijklmnopqrstuvwxyz");
    in
    (lib.findFirst (x: x.v == str) (throw "Element not found in list iteration") thelist).i;
}
