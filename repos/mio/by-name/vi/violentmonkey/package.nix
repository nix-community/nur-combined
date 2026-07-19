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
  version = "2.44.0";

  src = fetchFromGitHub {
    owner = "violentmonkey";
    repo = "violentmonkey";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LXI3pcKwdzpN02GCU6LODdmRRRoKfrTQeMg2hw/5EyQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-xAgU31U8D0qMs8P/dUox8YnZNgEa5fcIfhXyJdSpuE4=";
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
