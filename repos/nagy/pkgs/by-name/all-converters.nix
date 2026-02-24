{
  pkgs,
  lib,
  symlinkJoin,
}:

let
  self = import ../../. { inherit pkgs; };
in
symlinkJoin {
  name = "all-converters";
  paths = lib.pipe self.lib [
    (
      it:
      (lib.filterAttrs (
        name: value: (lib.hasPrefix "convert" name) && value ? fromSuffix && value ? toSuffix
      ) it)
    )
    lib.attrValues
  ];
}
