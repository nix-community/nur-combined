{
  sources,
  hash,
  pnpm_11,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  open-orpheus = callPackage ./package.nix { };
in
open-orpheus.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    version = "${prev.version}-unstable-${sources.date}";
    passthru = (prev.passthru or { }) // {
      # Regenerates the open-orpheus-dev pnpmDeps hash after nvfetcher bumps the source.
      updateScript = [ ./update.sh ];
    };
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_11;
      fetcherVersion = 4;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";
  }
)
