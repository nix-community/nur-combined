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
  version = "3.0.1-unstable-2026-03-23";

  src = fetchFromGitHub {
    owner = "zyronon";
    repo = "TypeWords";
    rev = "be42912ba03d08d62b4f9bb148398b93091c99d9";
    hash = "sha256-sBqC6fxvPPpgh6QBNcFNTyLbNVRvCErU2BKCRp44OlE=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-G9YL0Ef0JcBpjsfwgNG+S3IZBYs8j4ovlSLgtmGlxbQ=";
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
