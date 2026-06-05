{
  sources,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  splayer = callPackage ./package.nix {
  };
in
splayer.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    version = "${prev.version}-unstable-${sources.date}";
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 3;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";

    env.VITE_BUILD_TYPE = "dev";
  }
)
