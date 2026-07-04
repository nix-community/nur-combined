{
  lib,
  stdenv,
  sources,
  makeWrapper,
  python3,
}:

let
  pythonEnv = python3.withPackages (
    p: with p; [
      dbus-python
      websockets
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.lyrics-on-panel-backend) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ pythonEnv ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lyrics-on-panel-backend
    cp -r ${finalAttrs.src}/backend/src/* $out/lib/lyrics-on-panel-backend/

    mkdir -p $out/bin
    makeWrapper ${lib.getExe pythonEnv} $out/bin/lyrics-on-panel-backend \
      --add-flags "-m server" \
      --set PYTHONPATH "$out/lib/lyrics-on-panel-backend"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MPRIS2 WebSocket backend for the Lyrics-on-Panel KDE Plasma widget";
    homepage = "https://github.com/KangweiZhu/lyrics-on-panel";
    license = lib.licenses.gpl3Only;
    mainProgram = "lyrics-on-panel-backend";
    platforms = lib.platforms.linux;
  };
})
