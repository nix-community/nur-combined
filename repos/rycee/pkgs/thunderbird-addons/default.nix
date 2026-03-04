{
  buildMozillaXpiAddon,
  fetchurl,
  lib,
  stdenv,
}:

let

  generatedPackages = import ./generated-thunderbird-addons.nix {
    inherit
      buildMozillaXpiAddon
      fetchurl
      lib
      stdenv
      ;
  };

  packages = generatedPackages // {
    tbkeys = import ./tbkeys.nix {
      inherit
        buildMozillaXpiAddon
        lib
        ;
    };
  };

in
packages
