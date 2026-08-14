{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm,
  nodejs_22,
  fetchPnpmDeps,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "violentmonkey";
  version = "2.47.1";

  src = fetchFromGitHub {
    owner = "violentmonkey";
    repo = "violentmonkey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sGy97GcMven/hnMMjTTaWTEkl7P1XxaDRhAhTyC84Qc=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-TkD0/W7KOcCpUxyEWb0dtk7S5jphkf0J7PIEhP/bAeA=";
    fetcherVersion = 4;
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm.configHook
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
