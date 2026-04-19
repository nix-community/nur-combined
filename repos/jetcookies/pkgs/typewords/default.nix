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
  version = "3.0.1-unstable-2026-04-19";

  src = fetchFromGitHub {
    owner = "zyronon";
    repo = "TypeWords";
    rev = "aaa0fc55ca0f5fb1011cca487795319dac4e7e1e";
    hash = "sha256-BBJo7JmhETeXc6gBM0+8lFr7suFum6zEwwIAhNaEOqc=";
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
