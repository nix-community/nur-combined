{ stdenv
, weston
, makeDesktopItem
, makeWrapper
, copyDesktopItems
}: 
let 
  desktop = makeDesktopItem {
    name = "run-weston";
    exec = "run-weston";
    comment = "Start weston session";
    desktopName = "Weston";
    categories = [ "System" ];
    icon = "wayland";
  };
in stdenv.mkDerivation {
  name = "run-weston";

  dontUnpack = true;

  nativeBuildInputs = [ copyDesktopItems makeWrapper ];
  desktopItems = [ desktop ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${weston}/bin/weston $out/bin/run-weston \
      --set XDG_SESSION_TYPE wayland

    runHook postInstall
  '';
}
