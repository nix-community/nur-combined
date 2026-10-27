{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm,
  pnpmConfigHook,
  nodejs_22,
  fetchPnpmDeps,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "violentmonkey";
  version = "2.49.6";

  src = fetchFromGitHub {
    owner = "violentmonkey";
    repo = "violentmonkey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tILviyCOtlBka5XfoFk25JvEo3Pcvb00N44ikY3bEd8=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-P6H+3GMs41+yrO35raL+w/SjojIMNPrkUoXqMC+N+zE=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    nodejs_22
    pnpmConfigHook
    pnpm
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/violentmonkey
    # After build, it usually outputs to dist/
    cp -r dist/. $out/share/violentmonkey/
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/violentmonkey/violentmonkey/releases/tag/v${finalAttrs.version}";
    description = "Violentmonkey provides userscripts support for browsers";
    homepage = "https://violentmonkey.github.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
})
