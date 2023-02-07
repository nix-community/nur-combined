{ self }:
let
  inherit (self.lib) standardise-nix;
  inherit (self.common) package-sets;
in builtins.mapAttrs (name: value:
  let inherit (value.lib.strings) hasSuffix;
  in standardise-nix {
    pkgs = value;
    stable = hasSuffix "stable" name;
  }) package-sets
