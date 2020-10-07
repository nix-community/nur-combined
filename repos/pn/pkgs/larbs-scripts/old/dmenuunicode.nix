{ stdenv, callPackage }:
let
  voidrice = callPackage ../voidrice.nix { };
  dmenu = callPackage ../dmenu { };
in
stdenv.mkDerivation {
  name = "dmenuunicode";

  src = voidrice;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share
    cp .local/share/larbs/emoji $out/share

    sed -i "s:~/.local/share/larbs/emoji:$out/share/emoji:" .local/bin/dmenuunicode
    sed -i "s:dmenu:${dmenu}/bin/dmenu:g" .local/bin/dmenuunicode
    cp .local/bin/dmenuunicode $out/bin
  '';
}
