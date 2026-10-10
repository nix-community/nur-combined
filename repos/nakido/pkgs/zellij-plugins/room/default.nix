
{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "room";
  version = "1.2.1";

  src = fetchurl {
    url = "https://github.com/rvcas/room/releases/download/v${version}/room.wasm";
    sha256 = "sha256-kLSDpAt2JGj7dYYhYFh6BfvtzVwTrcs+0jHwG/nActE=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 "$src" "$out/share/zellij/plugins/${pname}-${version}.wasm"

    runHook postInstall
  '';

  meta = with lib; {
    description = "A Zellij plugin for quickly searching and switching between tabs";
    homepage = "https://github.com/rvcas/room";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    platforms = platforms.linux;
  };
}