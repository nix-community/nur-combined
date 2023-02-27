{ self }:
let
  inherit (self.lib) standardise-nix;
  inherit (self.common) package-sets;
in builtins.mapAttrs (name: value:
  let inherit (value.lib.strings) hasSuffix;
  in standardise-nix {
    pkgs = value;
    # Check for existence of unstable, if false we know we're using
    # stable rahter than unstable
    stable = !(hasSuffix "unstable" name);
  }) package-sets
