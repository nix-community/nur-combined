{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  python3,
  makeWrapper,
}:
let
  py = python3.withPackages (
    p: with p; [
      pytest
      pytest-asyncio
      python-dateutil
      requests
      verboselogs
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "decluttarr";
  version = "2.1.0";
  src = fetchFromGitHub {
    owner = "ManiMatter";
    repo = "decluttarr";
    tag = "v1.50.2";
    hash = "sha256-62NdvCn2/AmSZiVklFwt40hRBOG4VuV+ubFAo3tCsmE=";
  };
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${lib.getExe py} $out/bin/decluttarr \
      --add-flags $src/main.py

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Watches radarr, sonarr, lidarr and readarr download queues and removes downloads if they become stalled or no longer needed";
    homepage = "https://github.com/ManiMatter/decluttarr";
    license = with lib.licenses; [ gpl3Only ];
    mainProgram = "decluttarr";
  };
})
