{
  lib,
  callPackage,
  stdenv,
  rustPlatform,
  nix-update-script,
  fetchFromForgejo,
  fetchPnpmDeps,
  pnpm_12,
  pnpmConfigHook,
  nodejs_26,
  wasm-bindgen-cli_0_2_129,
  llvmPackages,
  binaryen,
  withDeepfilternet ? false,
}:

let
  pnpm = pnpm_12;
  nodejs = nodejs_26;
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_129;
  deepfilternet = callPackage ./deepfilternet.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-next-unwrapped";
  version = "2.2.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.sable.moe";
    owner = "SableClient";
    repo = "sable-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vMzTblJ+JvW18fwW6npOPsGJOxroUDP2GSAXUklEbo8=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-j5Lvvbf8d2Mo+E4gU/cYCDZUc6zDUzMjjPpkvNHSaXw=";
  };

  postPatch = lib.optionalString withDeepfilternet ''
    cp --no-preserve all -r ${finalAttrs.passthru.deepfilternet} static/deepfilternet3
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
    hash = "sha256-zHsBR55ZvMBkmQF8VhTXutbmaQX/6A4z4CMYoMb+tl8=";
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

  passthru = {
    updateScript = nix-update-script { };
    inherit deepfilternet;
  };

  meta = {
    description = "Sable rewrite in Rust and Svelte. An almost stable Matrix client";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    changelog = "https://git.sable.moe/SableClient/sable-next/src/tag/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
