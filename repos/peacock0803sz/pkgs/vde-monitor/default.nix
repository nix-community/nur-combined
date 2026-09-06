{ lib, stdenv, fetchFromGitHub, nodejs_24, pnpm_10, makeWrapper }:
stdenv.mkDerivation (finalAttrs: {
  pname = "vde-monitor";
  version = "0.14.22";

  src = fetchFromGitHub {
    owner = "yuki-yano";
    repo = "vde-monitor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ozw8slDKwJ1ehCsth/LqUKnJPcs4hJOn//rkdS6HEDQ=";
  };

  pnpmDeps = pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 4;
    hash = "sha256-A650SPR/DjouQW2S6Byf+6dKZA78HkN2vVw7W+8+XMA=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpm_10.configHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/vde-monitor $out/bin
    cp -r dist node_modules package.json $out/lib/vde-monitor/

    # The pnpm workspace members (@vde-monitor/*) are symlinked into the hoisted
    # fallback dir, but their targets (apps/, packages/) are not installed.
    # tsdown bundles them into dist/, so they are unused at runtime.
    rm -rf $out/lib/vde-monitor/node_modules/.pnpm/node_modules/@vde-monitor

    makeWrapper ${lib.getExe nodejs_24} $out/bin/vde-monitor \
      --add-flags $out/lib/vde-monitor/dist/index.js
    makeWrapper ${lib.getExe nodejs_24} $out/bin/vde-monitor-hook \
      --add-flags $out/lib/vde-monitor/dist/vde-monitor-hook.js
    runHook postInstall
  '';

  meta = {
    description = "Monitor coding sessions across supported terminal backends with a web UI";
    homepage = "https://github.com/yuki-yano/vde-monitor";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "vde-monitor";
  };
})
