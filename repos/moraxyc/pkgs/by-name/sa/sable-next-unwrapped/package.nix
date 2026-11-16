{
  lib,
  stdenv,
  rustPlatform,
  fetchPnpmDeps,
  pnpm,
  pnpmConfigHook,
  nodejs,
  wasm-bindgen-cli,
  binaryen,
  lld,
  llvmPackages,

  sources,
  source ? sources.sable-next,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sable-next-unwrapped";
  inherit (source) version src;

  __structuredAttrs = true;
  strictDeps = true;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = source.pnpmDepsHash;
  };

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
    wasm-bindgen-cli
    binaryen
    lld
    rustPlatform.rust.rustc
    rustPlatform.rust.cargo
    rustPlatform.cargoSetupHook
  ];

  env = {
    CC_wasm32_unknown_unknown = lib.getExe llvmPackages.clang-unwrapped;
    AR_wasm32_unknown_unknown = lib.getExe' llvmPackages.bintools-unwrapped "llvm-ar";
    SABLE_FOSS = "1";
    VITE_APP_VERSION = finalAttrs.version;
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';

  meta = {
    description = "Sable rewrite in Rust and Svelte, a Matrix client (web build)";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    changelog = "https://git.sable.moe/SableClient/sable-next/src/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.all;
  };
})
