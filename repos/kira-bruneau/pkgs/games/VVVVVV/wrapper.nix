{ lib
, stdenvNoCC
, callPackage
, makeDesktopItem
, fetchurl
, Foundation
, makeWrapper
, unzip
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
in
stdenvNoCC.mkDerivation {
  pname = "VVVVVV";
  inherit (VVVVVV) version;

  # Obtain data.zip from Make and Play edition
  src = fetchurl {
    url = "https://thelettervsixtim.es/makeandplay/data.zip";
    hash = "sha256-b6483sBgYtBYJ9QYHEOBU/PqOQBDekTbc7zSl5n+V+A=";
    meta.licence = lib.licenses.unfree;
  };

  nativeBuildInputs = [ makeWrapper unzip ];

  # Unzip must be done manually
  # It returns a non-zero exit code due to an encoding mismatch
  unpackPhase = ''
    runHook preUnpack
    unzip -q $src || true
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin" "$out/share/VVVVVV" "$out/share/applications" "$out/share/pixmaps"

    makeWrapper ${VVVVVV}/bin/VVVVVV "$out/bin/VVVVVV" \
      --run "cd $out/share/VVVVVV"

    cp $src "$out/share/VVVVVV/data.zip"
    cp ${desktopItem}/share/applications/* "$out/share/applications"
    cp VVVVVV.png "$out/share/pixmaps"
    runHook postInstall
  '';

  meta = VVVVVV.meta // (with lib; {
    license = licenses.unfree;
  });
}
