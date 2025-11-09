{
  stdenvNoCC,
  sources,
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
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.decluttarr) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${py}/bin/python3 $out/bin/decluttarr \
      --add-flags $src/main.py

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Watches radarr, sonarr, lidarr and readarr download queues and removes downloads if they become stalled or no longer needed";
    homepage = "https://github.com/ManiMatter/decluttarr";
    license = with lib.licenses; [ gpl3Only ];
    mainProgram = "decluttarr";
  };
})
