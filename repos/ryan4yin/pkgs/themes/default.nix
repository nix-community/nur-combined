{
  lib,
  pkgs,
}:
# execute and callPackge in the current directory with the given args
# FYI: `lib.genAttrs [ "foo" "bar" ] (name: "x_" + name)` => `{ foo = "x_foo"; bar = "x_bar"; }`
lib.genAttrs
(builtins.filter # find all overlay files in the current directory
  
  (
    f:
      f
      != "default.nix" # ignore default.nix
      && f != "README.md" # ignore README.md
  )
  (builtins.attrNames (builtins.readDir ./.)))
(name: (pkgs.callPackage (./. + "/${name}") {}))
