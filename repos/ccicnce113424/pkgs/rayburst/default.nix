{
  sources,
  version,
  hash,
  pnpm_11,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  rayburst = callPackage ./package.nix { };
in
rayburst.overrideAttrs (
  final: _prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_11;
      fetcherVersion = 4;
    };
    cargoHash = null;
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."src-tauri/Cargo.lock";
  }
)
