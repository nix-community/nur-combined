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
  version = "3.0.1-unstable-2026-03-30";

  src = fetchFromGitHub {
    owner = "zyronon";
    repo = "TypeWords";
    rev = "7e359dd1fe5532c2e80f799fd2861c265721c256";
    hash = "sha256-lGFviYldOuShegHhG/sZ5F6SUxN4HPt8mfa/IJ5RoB8=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-skUqKRsbO9pZwn8QEMUUwlhMcxkNZ8VV+IKhVOoTAoI=";
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
