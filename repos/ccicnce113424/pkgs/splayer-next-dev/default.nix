{
  sources,
  hash,
  pnpm_11,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
  dbus,
}:
let
  splayer-next = callPackage ./package.nix { };
in
splayer-next.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    version = "${prev.version}-unstable-${sources.date}";
    passthru = (prev.passthru or { }) // {
      # Regenerates the splayer-next-dev pnpmDeps hash after nvfetcher bumps the source.
      updateScript = [ ./update.sh ];
    };
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_11;
      fetcherVersion = 4;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";
    prePatch = prev.prePatch + ''
      echo ${sources.src.rev} > COMMIT
    '';
    buildInputs = prev.buildInputs ++ [ dbus ];
  }
)
