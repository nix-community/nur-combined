{
  sources,
  version,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  splayer = callPackage ./package.nix { };
in
splayer.overrideAttrs (
  final: _prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 2;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";

    env.VITE_BUILD_TYPE = "dev";
  }
)
