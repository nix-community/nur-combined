{
  lib,
  stdenvNoCC,
  fetchFromGitHub,

  fetchPnpmDeps,
  makeBinaryWrapper,
  nodejs_24,
  pnpm,
  pnpmConfigHook,

  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jellarr";
  version = "0.1.0-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "venkyr77";
    repo = "jellarr";
    rev = "de530bc0117eb4018598a67245e748623a6ce6dc";
    hash = "sha256-hSwb4Jg0JGkrQeEck7spTPBtvIfiIPMkIgBPO0dgqJs=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-jo1BjRAjjfNKF0xb5cLCuELSveHeJ98iLPhMDKP1QbI=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs_24
    pnpm
    pnpmConfigHook
  ];

  env.CI = "true";

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/jellarr bundle.cjs
    makeWrapper ${lib.getExe nodejs_24} $out/bin/jellarr \
      --add-flags "$out/share/jellarr/bundle.cjs"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-jellarr-help"
        {
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          jellarr --help | grep -q apply
          jellarr dump --help | grep -q baseUrl
          touch $out
        '';
  };

  meta = {
    description = "Declarative configuration engine for Jellyfin";
    homepage = "https://github.com/venkyr77/jellarr";
    license = lib.licenses.agpl3Only;
    mainProgram = "jellarr";
    platforms = lib.platforms.all;
  };
})
