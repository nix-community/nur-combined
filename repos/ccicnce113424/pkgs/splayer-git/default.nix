{
  sources,
  version,
  hash,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  lib,
  electron,
  removeReferencesTo,
  python3,
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

    env.VITE_BUILD_TYPE = "dev";

    # remove when splayer in nixpkgs has been updated
    nativeBuildInputs = prev.nativeBuildInputs ++ [ python3 ];
    # After the pnpm configure, we need to build the binaries of all instances
    # of better-sqlite3. It has a native part that it wants to build using a
    # script which is disallowed.
    # What's more, we need to use headers from electron to avoid ABI mismatches.
    # Adapted from mkYarnModules.
    preBuild = ''
      for f in $(find . -path '*/node_modules/better-sqlite3' -type d); do
        (cd "$f" && (
        npm run build-release --offline --nodedir="${electron.headers}"
        find build -type f -exec \
          ${lib.getExe removeReferencesTo} \
          -t "${electron.headers}" {} \;
        ))
      done
    '';

    meta = prev.meta // {
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        # public/wasm/decode-audio.wasm
        # source: https://github.com/apoint123/ffmpeg-audio-player
        binaryBytecode
      ];
    };
  }
)
