{
  sources,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  dorion = callPackage ./package.nix {
  };
in
dorion.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    version = "${prev.version}-unstable-${sources.date}";
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 3;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."src-tauri/Cargo.lock";
    patches = [
      ./dont-disable-dma.patch
      ./notification-icon.patch
    ];
  }
)
