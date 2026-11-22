{
  lib,
  stdenv,
  rustPlatform,
  sable-next-unwrapped,
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
stdenv.mkDerivation (_finalAttrs: {
  pname = "sable-next-wasm";
  inherit (sable-next-unwrapped)
    version
    src
    patches
    cargoDeps
    pnpmDeps
    ;

  __structuredAttrs = true;
  strictDeps = true;

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

  env = {
    AR_wasm32_unknown_unknown = lib.getExe' llvmPackages.bintools-unwrapped "llvm-ar";
    CC_wasm32_unknown_unknown = lib.getExe llvmPackages.clang-unwrapped;
    SABLE_WASM_OUTPUT = lib.placeholder "out";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run wasm:build

    runHook postBuild
  '';

  meta = {
    inherit (sable-next-unwrapped.meta)
      description
      homepage
      changelog
      license
      maintainers
      ;
  };
})
