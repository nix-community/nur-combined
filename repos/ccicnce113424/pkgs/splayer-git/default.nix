{
  sources,
  version,
  hash,
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
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";

    # remove when splayer in nixpkgs has been updated
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      rustPlatform.cargoSetupHook
      cargo
      rustc
    ];

    postPatch = ''
      # Workaround for https://github.com/electron/electron/issues/31121
      substituteInPlace electron/main/utils/native-loader.ts \
        --replace-fail 'process.resourcesPath' "'$out/share/splayer/resources'"
    '';
  }
)
