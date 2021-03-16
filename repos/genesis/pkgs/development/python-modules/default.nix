{ callPackage }:

rec {
  frida = callPackage ./frida.nix { };
  pycotap = callPackage ./pycotap { };
  pysol_cards = callPackage ./pysol_cards { };
}
