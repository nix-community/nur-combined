{
  sources,
  hash,
  pnpm_10,
  electron_40,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  splayer = callPackage ./package.nix {
    # 续命，不过electron 40很快也要eol了
    electron_39 = electron_40;
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

    strictDeps = true;
    __structuredAttrs = true;
  }
)
