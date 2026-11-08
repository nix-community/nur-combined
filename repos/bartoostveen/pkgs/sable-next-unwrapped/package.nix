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
  version = "2.3.6";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.sable.moe";
    owner = "SableClient";
    repo = "sable-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SOsJ+ZFWzOxg/ijfDzZnmXaxPMAU9B5XHGg4ieJAak8=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-7C8c0IEtA+/ev4WUL9DLfHSYVZ3P9jZf4h+KIICV6GM=";
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
    hash = "sha256-SP8VW5AXFhZ9jr6XhrsH4w8cJUYcsoeSqXo8gGrjlng=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
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
