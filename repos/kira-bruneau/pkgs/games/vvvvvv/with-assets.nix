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
  vvvvvv = callPackage ./default.nix { inherit Foundation; };
  desktopItem = makeDesktopItem {
    name = vvvvvv.pname;
    desktopName = "VVVVVV";
    genericName = vvvvvv.meta.description;
    icon = "VVVVVV";
    exec = "VVVVVV";
    categories = [ "Game" ];
  };
in
stdenvNoCC.mkDerivation {
  pname = "vvvvvv-with-assets";
  inherit (vvvvvv) version;

  # Obtain data.zip from Make and Play edition
  src = fetchurl {
    url = "https://thelettervsixtim.es/makeandplay/data.zip";
    sha256 = "sha256-x2eAlZT2Ry2p9WE252ZX44ZA1YQWSkYRIlCsYpPswOo=";
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

    mkdir -p \
     "$out/share/VVVVVV" \
     "$out/share/applications" \
     "$out/share/pixmaps" \
     "$out/bin"

    cp $src "$out/share/VVVVVV/data.zip"
    cp ${desktopItem}/share/applications/* "$out/share/applications"
    cp VVVVVV.png "$out/share/pixmaps"
    ln -s ${vvvvvv}/share/licenses "$out/share"

    makeWrapper ${vvvvvv}/bin/VVVVVV "$out/bin/VVVVVV" \
      --add-flags "-assets $out/share/VVVVVV/data.zip"

    runHook postInstall
  '';

  passthru.unwrapped = vvvvvv;

  meta = vvvvvv.meta // (with lib; {
    license = licenses.unfree;
    mainProgram = "VVVVVV";
  });
}
