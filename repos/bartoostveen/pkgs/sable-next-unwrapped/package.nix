{
  lib,
  callPackage,
  stdenv,
  rustPlatform,
  nix-update-script,
  fetchFromForgejo,
  fetchPnpmDeps,
  pnpm_11,
  pnpmConfigHook,
  nodejs_26,
  wasm-bindgen-cli_0_2_129,
  llvmPackages,
  binaryen,
}:

let
  pnpm = pnpm_11;
  nodejs = nodejs_26;
  wasm-bindgen-cli = wasm-bindgen-cli_0_2_129;
  deepfilternet = callPackage ./deepfilternet.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-next-unwrapped";
  version = "2.0.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.sable.moe";
    owner = "SableClient";
    repo = "sable-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GgX9EQOMn80X35wLpsZF96TF4tUHadWYoFDzBcGKdA4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-TLz9XwQOn/DRZa+OILYYvh+xMrTYLcrB1vfdXJJUjcQ=";
  };

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "mise exec --" ""

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
    fetcherVersion = 4;
    hash = "sha256-3kZWOasVMNk/2njTnNY7zrBTlmyW5w+9jXiEJgx9NNc=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
  };

  buildPhase = ''
    runHook preBuild

    pnpm -- config set nodeOptions "--max-old-space-size=4096"
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
