{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,

  nodejs,
  pnpm,
  pnpmConfigHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {

  pname = "typewords";
  version = "3.0.2-unstable-2026-04-27";

  src = fetchFromGitHub {
    owner = "zyronon";
    repo = "TypeWords";
    rev = "45dbac5012ef9823083ee094c462dcd97999be75";
    hash = "sha256-74+DiRg64d+1AviBjwbKHdcvdUHlBE43OdjCcNUGtLc=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-X0aPPh1Xiv/gmBQWgEH08Mi71uxLYqih65qXsT/6G5I=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ];

  NUXT_TELEMETRY_DISABLED = 1;

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Practice English, one strike, one step forward";
    homepage = "https://github.com/zyronon/TypeWords";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
