{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  meta = with lib; {
    description = "A configurable statusbar plugin for zellij";
    homepage = "https://github.com/dj95/zjstatus";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.linux;
    mainProgram = null;
  };

  pname = "zjstatus";
  version = "0.22.0";

  src = fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v${version}/zjstatus.wasm";
    sha256 = "sha256-TeQm0gscv4YScuknrutbSdksF/Diu50XP4W/fwFU3VM=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/zellij/plugins
    cp $src $out/share/zellij/plugins/zjstatus-${version}.wasm

    runHook postInstall
  '';
}