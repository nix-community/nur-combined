{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
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
  pname = "lyrics-on-panel-backend";
  version = "2.0";
  src = fetchFromGitHub {
    owner = "KangweiZhu";
    repo = "lyrics-on-panel";
    tag = "v2.0";
    hash = "sha256-r7eoDm92k1ZjnBOtIt09a6P2MMLItqva6aXgLmqk3no=";
  };
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

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MPRIS2 WebSocket backend for the Lyrics-on-Panel KDE Plasma widget";
    homepage = "https://github.com/KangweiZhu/lyrics-on-panel";
    license = lib.licenses.gpl3Only;
    mainProgram = "lyrics-on-panel-backend";
    platforms = lib.platforms.linux;
  };
})
