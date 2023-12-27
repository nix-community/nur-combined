{
  lib,
  pkgs,
}:
# execute and callPackge in the current directory with the given args
# FYI: `lib.genAttrs [ "foo" "bar" ] (name: "x_" + name)` => `{ foo = "x_foo"; bar = "x_bar"; }`
lib.genAttrs
(builtins.attrNames
  (lib.attrsets.filterAttrs
    (
      path: _type:
        (_type == "directory") # include directories
        || (
          (path != "default.nix") # ignore default.nix
          && (lib.strings.hasSuffix ".nix" path) # include .nix files
        )
    )
    (builtins.readDir ./.)))
(name: (pkgs.callPackage (./. + "/${name}") {}))
