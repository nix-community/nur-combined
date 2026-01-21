{
  sources,
  version,
  pnpm_10,
  fetchPnpmDeps,
  rustPlatform,
  lib,
  electron,
  removeReferencesTo,
  python3,
  wasm-pack,
  rustc,
  binaryen,
  splayer,
  wasm-bindgen-cli_0_2_106,
}:
splayer.overrideAttrs (
  final: prev: {
    inherit (sources) pname src;
    inherit version;
    pnpmDeps = fetchPnpmDeps {
      inherit (final) pname version src;
      hash = "sha256-tAOtrxQasIQ1IS2jKdcX4KEM5p3zhshqw8phzsj667Q=";
      pnpm = pnpm_10;
      fetcherVersion = 2;
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (final) src patches;
      hash = "sha256-2q/yaj2Fa9jaxSz5ftSa+2eTzPqt8vvGed8FZ/Whj7o=";
    };

    # remove when splayer in nixpkgs has been updated
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      python3
      wasm-pack
      wasm-bindgen-cli_0_2_106
      rustc.llvmPackages.lld
      binaryen
    ];

    patches = [ ./fix-ferrous-opencc.patch ];

    # add env to build.rollupOptions.external in electron.vite.config.ts
    postPatch = prev.postPatch + ''
      sed -i 's/"external-media-integration\.node"/"external-media-integration.node", "env"/g' electron.vite.config.ts
    '';
    buildPhase = ''
      runHook preBuild      

      # After the pnpm configure, we need to build the binaries of all instances
      # of better-sqlite3. It has a native part that it wants to build using a
      # script which is disallowed.
      # What's more, we need to use headers from electron to avoid ABI mismatches.
      # Adapted from mkYarnModules.
      for f in $(find . -path '*/node_modules/better-sqlite3' -type d); do
        (cd "$f" && (
        pnpm run build-release --offline --nodedir="${electron.headers}"
        find build -type f -exec \
          ${lib.getExe removeReferencesTo} \
          -t "${electron.headers}" {} \;
        ))
      done

      pnpm --filter external-media-integration build

      pushd native/ferrous-opencc-wasm
      CFLAGS_wasm32_unknown_unknown="-Wno-implicit-function-declaration" \
        wasm-pack build --target web
      popd

      SKIP_NATIVE_BUILD=true pnpm build

      npm exec electron-builder -- \
          --dir \
          --config electron-builder.config.ts \
          -c.electronDist=${electron.dist} \
          -c.electronVersion=${electron.version}

      runHook postBuild
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
