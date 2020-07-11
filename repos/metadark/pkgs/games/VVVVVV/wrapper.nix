{ stdenvNoCC
, callPackage, makeDesktopItem, fetchurl
, Foundation
, makeWrapper, unzip
}:

let
  VVVVVV = callPackage ./default.nix { inherit Foundation; };
  desktopItem = makeDesktopItem {
    name = "VVVVVV";
    desktopName = "VVVVVV";
    genericName = VVVVVV.meta.description;
    icon = "VVVVVV";
    exec = "VVVVVV";
    categories = "Game;";
  };
in stdenvNoCC.mkDerivation {
  pname = "VVVVVV";
  inherit (VVVVVV) version;

  # Obtain data.zip from Make and Play edition
  src = fetchurl {
    url = "https://thelettervsixtim.es/makeandplay/data.zip";
    sha256 = "1q2pzscrglmwfgdl8yj300wymwskh51iq66l4xcd0qk0q3g3rbkg";
    meta.licence = stdenvNoCC.lib.licenses.unfree;
  };

  nativeBuildInputs = [ makeWrapper unzip ];

  # Unzip must be done manually
  # It returns a non-zero exit code due to an encoding mismatch
  unpackPhase = "unzip -q $src || true";

  installPhase = ''
    mkdir -p "$out/bin" "$out/share/VVVVVV" "$out/share/applications" "$out/share/pixmaps"

    makeWrapper ${VVVVVV}/bin/VVVVVV "$out/bin/VVVVVV" \
      --run "cd $out/share/VVVVVV"

    cp $src "$out/share/VVVVVV/data.zip"
    cp ${desktopItem}/share/applications/* "$out/share/applications"
    cp VVVVVV.png "$out/share/pixmaps"
  '';

  meta = VVVVVV.meta // {
    license = stdenvNoCC.lib.licenses.unfree;
  };
}
