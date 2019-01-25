{ callPackage }:
rec {
  hkp4py = callPackage ./hkp4py.nix {};
  cmakeconverter = callPackage ./cmakeconverter.nix {};
}
