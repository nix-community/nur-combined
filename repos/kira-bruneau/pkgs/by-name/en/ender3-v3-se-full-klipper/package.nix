{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ender3-v3-se-full-klipper";
  version = "0-unstable-2024-01-24";

  src = fetchFromGitHub {
    owner = "bootuz-dinamon";
    repo = "ender3-v3-se-full-klipper";
    rev = "93e6d506376137d57d19e0ffc3c2c8f4ed491ea0";
    hash = "sha256-Noq/7BWB3PH6X2FYDOJ10cAot3KFY4mXU+SoLZLVX+c=";
  };

  outputs = [
    "out"
    "nebula_pad"
  ];

  installPhase = ''
    runHook preInstall
    rm *.bin
    mv 'Config from Nebula pad' "$nebula_pad"
    cp -r . "$out"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Configuration files for Klipper for Ender3 V3 SE";
    homepage = "https://github.com/bootuz-dinamon/ender3-v3-se-full-klipper";
    maintainers = with lib.maintainers; [ kira-bruneau ];
    mainProgram = "ender3-v3-se-full-klipper";
    platforms = lib.platforms.all;
  };
})
