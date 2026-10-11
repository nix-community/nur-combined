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
  final: prev: {
    inherit (sources) pname src;
    inherit version;
    passthru = (prev.passthru or { }) // {
      updateScript = [ ./update-beta.sh ];
    };
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
