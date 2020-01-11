{ stdenvNoCC, callPackage, makeDesktopItem, fetchurl
, makeWrapper, unzip }:

let
  vvvvvv = callPackage ./default.nix {};
  desktopItem = makeDesktopItem {
    name = "vvvvvv";
    desktopName = "VVVVVV";
    genericName = vvvvvv.meta.description;
    icon = "vvvvvv";
    exec = "vvvvvv";
    categories = "Game;";
  };
in stdenvNoCC.mkDerivation {
  inherit (vvvvvv) pname version;

  # Obtain data.zip from Make and Play edition
  src = fetchurl {
    url = "http://www.flibitijibibo.com/VVVVVV-MP-10202016.zip";
    sha256 = "14fd5d3pmpq4kjlbsxjqb34i3q77x5q72jmn6y5brs3widpfgyrr";
  };

  nativeBuildInputs = [ makeWrapper unzip ];

  # Unzip succeeds, but returns non-zero exit code due to an encoding mismatch
  buildPhase = "unzip -q data.zip -d data || true";

  installPhase = ''
    mkdir -p "$out/bin" "$out/share/vvvvvv" "$out/share/applications" "$out/share/pixmaps"

    makeWrapper ${vvvvvv}/bin/vvvvvv "$out/bin/vvvvvv" \
      --run "cd $out/share/vvvvvv"

    cp data.zip "$out/share/vvvvvv"
    cp ${desktopItem}/share/applications/* "$out/share/applications"
    cp data/VVVVVV.png "$out/share/pixmaps/vvvvvv.png"
  '';

  meta = vvvvvv // {
    license = stdenvNoCC.lib.licenses.unfree;
  };
}
