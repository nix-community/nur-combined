{ 
lib,
fetchurl,
stdenv,
autoPatchelfHook,
appimage-run,
mesa,
xorg,
alsa-lib,
pango,
libGL,
libgpg-error,
gtk3,
}:
let
  pname = "suyu-room";
  version = "0.0.3";

  src = fetchurl {
    url = "https://git.suyu.dev/suyu/suyu/releases/download/v${version}/Suyu-Linux_x86_64.AppImage";
    hash = "sha256-26sWhTvB6K1i/K3fmwYg5pDIUi+7xs3dz8yVj5q7H0c=";
  };

in stdenv.mkDerivation rec {
  inherit pname version src;

  unpackCmd = "appimage-run -x . $src";
  sourceRoot = ".";

  nativeBuildInputs = [
    appimage-run
    autoPatchelfHook
  ];

  buildInputs = [
    mesa
    alsa-lib
    pango
    libGL
    libgpg-error
    gtk3
    xorg.libSM
    xorg.libICE
  ];

  installPhase = ''
    mkdir -p $out
    cp -r usr/* $out
    rm $out/bin/suyu
    rm $out/lib/libgtk-3.so.0
    rm $out/lib/libgdk-3.so.0
  '';

  meta = with lib; {
    description = "Create host server for Suyu";
    homepage = "https://git.suyu.dev/suyu/suyu";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    hydraPlatforms = [ ];
    license = with licenses; [ gpl3Plus ];
  };
}
