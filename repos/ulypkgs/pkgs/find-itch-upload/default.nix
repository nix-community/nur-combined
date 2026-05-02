{
  lib,
  stdenvNoCC,
  python3,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "find-itch-upload";
  version = "1.0.0";

  dontUnpack = true;

  buildInputs = [
    python3
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ${./main.py} $out/bin/$NIX_MAIN_PROGRAM

    runHook postInstall
  '';

  meta = {
    description = "Utility to retrieve the latest upload ID from itch.io";
    maintainer = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.all;
    mainProgram = "find-itch-upload";
  };
})
