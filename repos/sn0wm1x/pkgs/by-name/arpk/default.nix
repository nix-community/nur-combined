{
  fetchFromGitHub,
  lib,
  makeWrapper,
  nodejs_22,
  pnpm,
  stdenvNoCC,
  testers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "arpk";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "moeru-ai";
    repo = "arpk";
    rev = "refs/tags/v${finalAttrs.version}";
    hash = "sha256-FBc+i+cUl3W8ATrGbdbGN2AOKtv7/j4pbVq8LYbrVy0=";
  };

  nativeBuildInputs = [
    nodejs_22
    makeWrapper
    pnpm.configHook
  ];

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-e4fnnvDBPUpGFFBiVf5hpqK8VOtE4e1l2aYUg+xrlYs=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/node_modules/arpk}
    cp -r {dist,node_modules} $out/lib/node_modules/arpk

    makeWrapper ${lib.getExe nodejs_22} $out/bin/arpk --add-flags $out/lib/node_modules/arpk/dist/index.js

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "LLM as your translator, with DeepLX-compatible API";
    homepage = "https://github.com/moeru-ai/arpk";
    changelog = "https://github.com/moeru-ai/arpk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "arpk";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = nodejs_22.meta.platforms;
  };
})
