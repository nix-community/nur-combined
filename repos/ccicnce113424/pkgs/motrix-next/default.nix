{
  sources,
  version,
  hash,
  lib,
  stdenv,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  motrix-next = callPackage ./package.nix { };
in
motrix-next.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 3;
    };
    cargoHash = null;
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."src-tauri/Cargo.lock";

    preFixup =
      lib.optionalString stdenv.hostPlatform.isLinux ''
        gappsWrapperArgs+=(
          # fix NVIDIA issues with Tauri
          # https://github.com/tauri-apps/tauri/issues/9394#issuecomment-3795449374
          --set-default __NV_DISABLE_EXPLICIT_SYNC 1
        )
      ''
      + prev.preFixup;
  }
)
