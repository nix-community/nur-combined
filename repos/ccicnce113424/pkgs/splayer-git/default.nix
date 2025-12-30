{
  sources,
  version,
  hash ? "",
  cargoHash ? "",
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  cargo,
  rustc,
  splayer,
}:
splayer.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 2;
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final)
        pname
        src
        version
        ;
      hash = cargoHash;
    };
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      rustPlatform.cargoSetupHook
      cargo
      rustc
    ];
  }
)
