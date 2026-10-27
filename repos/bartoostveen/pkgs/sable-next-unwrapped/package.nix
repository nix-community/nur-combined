{
  lib,
  callPackage,
  stdenv,
  rustPlatform,
  nix-update-script,
  fetchFromForgejo,
  fetchPnpmDeps,
  fetchpatch,
  pnpm_12,
  pnpmConfigHook,
  nodejs_26,
  wasm-bindgen-cli_0_2_129,
  llvmPackages,
  binaryen,
  withDeepfilternet ? true,
}:

let
  pnpm = pnpm_12;
  nodejs = nodejs_26;
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_129;
  deepfilternet = callPackage ./deepfilternet.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-next-unwrapped";
  version = "2.2.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.sable.moe";
    owner = "SableClient";
    repo = "sable-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J5IIDdw9DLHBV7npugJeQ7U/4q11nRkSy/p7kzEBBMU=";
  };

  patches = [
    (fetchpatch {
      url = "https://git.sable.moe/SableClient/sable-next/pulls/1419.patch";
      hash = "sha256-Az8qTSyipecCV18RgVbdhewidkVIFd7HXKwVRGXU2NM=";
    })
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-XOy7hf6AfbuEKKb9xKnKGyPrTsJ2TTZRpUhwcm4+JsU=";
  };

  postPatch = lib.optionalString withDeepfilternet ''
    cp --no-preserve all -r ${finalAttrs.deepfilternet} static/deepfilternet3
  '';

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
    wasm-bindgen-cli

    # because the build script of sable-next probes the rustc version for some reason
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
    hash = "sha256-yGjMHlRCLAdF2cQXzqHDGCdxhECaErFrU5CHlzNblfM=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
  }
  // lib.optionalAttrs (!withDeepfilternet) {
    SABLE_SKIP_DEEPFILTERNET = true;
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

  inherit deepfilternet;

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
