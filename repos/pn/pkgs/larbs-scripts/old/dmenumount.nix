{ stdenv, callPackage, libnotify }:
let
  voidrice = callPackage ../voidrice.nix { };
  dmenu = callPackage ../dmenu { };
in
stdenv.mkDerivation {
  name = "dmenumount";

  src = voidrice;

  installPhase = ''
    mkdir -p $out/bin

    sed -i "s:dmenu:${dmenu}/bin/dmenu:g" .local/bin/dmenumount
    cp .local/bin/dmenumount $out/bin
  '';
}
