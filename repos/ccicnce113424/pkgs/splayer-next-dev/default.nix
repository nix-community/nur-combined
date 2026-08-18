{
  sources,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
  libpulseaudio,
}:
let
  splayer-next = callPackage ./package.nix { };
in
splayer-next.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    version = "${prev.version}-unstable-${sources.date}";
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_10;
      fetcherVersion = 4;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."Cargo.lock";
    buildInputs = prev.buildInputs ++ [ libpulseaudio ];
    postPatch = prev.postPatch + ''
      substituteInPlace electron/main/services/recognition/fingerprint.ts \
        --replace-fail 'process.resourcesPath' "'$out/share/splayer-next/resources'"
    '';
  }
)
