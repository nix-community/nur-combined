{
  sources,
  version,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  openssl,
  pkg-config,
  callPackage,
}:
let
  splayer = callPackage ./package.nix { };
in
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
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";

    env.VITE_BUILD_TYPE = "dev";

    buildInputs = (prev.buildInputs or [ ]) ++ [ openssl ];

    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkg-config
    ];
  }
)
