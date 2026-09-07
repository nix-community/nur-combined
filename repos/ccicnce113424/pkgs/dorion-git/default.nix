{
  sources,
  hash,
  pnpm_11,
  fetchPnpmDeps,
  rustPlatform,
  callPackage,
}:
let
  dorion = callPackage ./package.nix {
    pnpm_10 = pnpm_11;
  };
in
dorion.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    version = "${prev.version}-unstable-${sources.date}";
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      inherit hash;
      pnpm = pnpm_11;
      fetcherVersion = 4;
    };
    cargoDeps = rustPlatform.importCargoLock sources.cargoLock."src-tauri/Cargo.lock";
    patches = [
      ./dont-disable-dma.patch
      ./notification-icon.patch
    ];
    postPatch =
      builtins.replaceStrings [ ''"$cargoDepsCopy"/*'' ] [ ''"$cargoDepsCopy"/{.,*}'' ]
        prev.postPatch;
  }
)
