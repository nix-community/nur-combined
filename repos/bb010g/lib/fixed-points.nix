{ lib, libSuper }:

let
  inherit (lib.fixedPoints)
    composeExtensions
    composeExtensionList # (mod)
  ;
  inherit (lib.lists)
    foldl1'
  ;
in {

  composeExtensionList =
    fs:
    if fs == [ ]
      then (self: super: { })
      else foldl1' composeExtensions fs;

}
