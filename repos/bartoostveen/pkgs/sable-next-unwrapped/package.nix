{
  lib,
  stdenv,
  rustPlatform,
  nix-update-script,
  fetchFromForgejo,
  fetchPnpmDeps,
  pnpm_12,
  pnpmConfigHook,
  nodejs_26,
  wasm-bindgen-cli_0_2_130,
  llvmPackages,
  binaryen,
}:

let
  pnpm = pnpm_12;
  nodejs = nodejs_26;
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_130;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-next-unwrapped";
  version = "26.11.3";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.sable.moe";
    owner = "SableClient";
    repo = "sable-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ris5iIygXBbVVxp1VwvWrxeAeodYiZz+dOYPoYIXnf4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-ZQLIkQQYEeh/dTRp0O8HIcJrYL1EKDDYtgyZJGPmnpI=";
  };

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
    wasm-bindgen-cli

    rustPlatform.rust.rustc
    rustPlatform.rust.cargo
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    llvmPackages.bintools

    binaryen
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 5;
    hash = "sha256-oCF8B2mrzt25/Qgjnqlf0amy7xGV31xiUlYLRm9HxEA=";
  };

  env = {
    AR_wasm32_unknown_unknown = lib.getExe' llvmPackages.bintools-unwrapped "llvm-ar";
    CC_wasm32_unknown_unknown = lib.getExe llvmPackages.clang-unwrapped;
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
    SABLE_FOSS = 1;
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sable rewrite in Rust and Svelte. An almost stable Matrix client";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    changelog = "https://git.sable.moe/SableClient/sable-next/src/tag/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
