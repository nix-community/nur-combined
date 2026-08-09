{
  lib,
  stdenv,
  stdenvNoCC,
  autoPatchelfHook,
  bun,
  clang,
  cmake,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  writableTmpDirAsHomeHook,
  nodejs,
  opus,
  pkg-config,
  python3,
  wayland,
  libxcb,
}:

let
  version = "17.2.12";
  pname = "oh-my-pi";

  src = fetchFromGitHub {
    owner = "can1357";
    repo = "oh-my-pi";
    rev = "v${version}";
    hash = "sha256-FKB6oAIm+C5eMFWC64gGEdWadIdvqRAcovHjmzKBqUY=";
  };

  # Platform mapping
  isX86 = stdenvNoCC.hostPlatform.system == "x86_64-linux";
  rustArch = if isX86 then "x64" else "arm64";

  # ─────────────────────────────────────────────────
  # Phase 1: node_modules fixed-output derivation
  # ─────────────────────────────────────────────────
  node_modules = stdenvNoCC.mkDerivation {
    pname = "${pname}-node_modules";
    inherit version src;

    impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "SOCKS_SERVER"
    ];

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install \
        --cpu="x64" \
        --os="linux" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    outputHash = "sha256-LqtsOHAkWPPS5qGs+9mNGAhNRCwONWzFAORk1dfcb4k=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  # ─────────────────────────────────────────────────
  # Phase 2: Rust native addon
  # ─────────────────────────────────────────────────
  piNatives = rustPlatform.buildRustPackage {
    pname = "${pname}-pi-natives";
    inherit version src;

    cargoHash = "sha256-jKLaVNfQx31iCP7+srfwgKKhFNq2yTaUtV5LqcxhGow=";

    nativeBuildInputs = [
      clang
      cmake
      pkg-config
    ];

    buildInputs = [
      opus
      wayland
      libxcb
    ];

    RUSTC_BOOTSTRAP = "1";
    LIBCLANG_PATH = "${clang.cc.lib}/lib";

    # Use gcc.arch if user configured it (nix.conf gccarch-* → nixpkgs.config.gccArch)
    # Otherwise let upstream auto-detect: avx2 → modern/v3, else baseline/v2
    TARGET_PLATFORM = "linux";
    TARGET_ARCH = rustArch;
    TARGET_VARIANT = null;
    RUSTFLAGS =
      let
        arch = stdenvNoCC.hostPlatform.gcc.arch or null;
      in
      lib.optionalString (isX86 && arch != null) "-C target-cpu=${arch}";
    buildType = "ci";
    doCheck = false;

    cargoBuildFlags = [
      "-p"
      "pi-natives"
    ];

    preBuild = ''
      chmod -R u+w .
      cp -ra ${node_modules}/. .
      chmod -R u+w node_modules packages/*/node_modules 2>/dev/null || true
      patchShebangs node_modules 2>/dev/null || true

      export CARGO_TARGET_DIR="$TMPDIR/cargo-target"
      export CARGO_BUILD_TARGET_DIR="$TMPDIR/cargo-target"
      mkdir -p "$CARGO_TARGET_DIR"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/native"

      # Find the built cdylib .so file
      local so_file=$(find "$CARGO_TARGET_DIR" -name 'libpi_natives.so' -type f 2>/dev/null | head -1)
      if [ -z "$so_file" ]; then
        echo "ERROR: libpi_natives.so not found in CARGO_TARGET_DIR"
        exit 1
      fi

      # Determine variant: auto-detect AVX2
      local variant="baseline"
      if [ -r /proc/cpuinfo ] && grep -q '^flags.* avx2 ' /proc/cpuinfo 2>/dev/null; then
        variant="modern"
      fi

      cp "$so_file" "$out/native/pi_natives.linux-x64-$variant.node"

      # Copy JS/TS files from source
      cp -vr packages/natives/native/*.js "$out/native/" 2>/dev/null || true
      cp -vr packages/natives/native/*.d.ts "$out/native/" 2>/dev/null || true
      runHook postInstall
    '';

    dontStrip = true;

    meta = {
      description = "Native Rust addon for oh-my-pi";
      platforms = [
        "x86_64-linux"
      ];
    };
  };

  # ─────────────────────────────────────────────────
  # Phase 4: browser relay extension (CRX3)
  # ─────────────────────────────────────────────────
  # Stable extension identity for home-manager's programs.chromium.extensions
  # (`crxPath`). browser-relay-key.pem is a committed THROWAWAY key — it only
  # pins the CRX extension ID across rebuilds; it authenticates nothing else.
  # extensionId = sha256(SPKI DER of the key)[:16], nibbles mapped 0..f → a..p.
  extensionId = "lgcklnhmbedbnkhgepghbnojilibgani";

  browserRelayExtension = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "omp-browser-relay-extension";
    # Version of the extension manifest (packages/browser-relay/extension/
    # manifest.json), NOT the omp release version. home-manager writes this
    # into `external_version`; pack-crx3.py fails the build if upstream bumps
    # the manifest version and this drifts.
    version = "0.1.0";
    inherit src;
    sourceRoot = "${src.name}/packages/browser-relay";

    nativeBuildInputs = [
      bun
      (python3.withPackages (ps: [ ps.cryptography ]))
    ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      runHook preBuild
      # Same as upstream scripts/build-extension.ts (Bun.build + asset copy),
      # minus the zip and CLI-asset embedding. Relative entrypoint keeps the
      # banner comment identical to the release-zip background.js.
      bun build extension/background.ts --outdir=dist --target=browser
      cp extension/manifest.json extension/options.html extension/options.js dist/
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      python3 ${./pack-crx3.py} dist ${./browser-relay-key.pem} $out \
        --expect-id ${extensionId} \
        --expect-version ${finalAttrs.version}
      runHook postInstall
    '';

    passthru = {
      id = extensionId;
    };

    meta = {
      description = "Lets the omp coding agent drive your existing tabs through a local CDP relay";
      homepage = "https://github.com/can1357/oh-my-pi/tree/main/packages/browser-relay";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  });

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version src;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    bun
    nodejs
    makeBinaryWrapper
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  configurePhase = ''
    runHook preConfigure

    # Copy source tree
    cp -R ${src}/. .
    chmod -R u+w .

    # Relax Bun version check (nixpkgs bun is 1.3.13, upstream wants >=1.3.14)
    substituteInPlace packages/coding-agent/src/cli.ts \
      --replace-fail \
        'error: Bun runtime must be >= ' \
        'warn: Bun runtime must be >= '
    # Also prevent process.exit(1) after the version warning
    substituteInPlace packages/coding-agent/src/cli.ts \
      --replace-fail \
        'process.exit(1)' \
        'process.exit(0)'
    # Patch MIN_BUN_VERSION to match nixpkgs bun version
    substituteInPlace packages/utils/src/dirs.ts \
      --replace-fail \
        'engines.bun.replace(/[^0-9.]/g, "")' \
        '"1.3.13"'

    # Overlay node_modules
    cp -R ${node_modules}/. .
    chmod -R u+w node_modules packages/*/node_modules 2>/dev/null || true

    # Overlay native addon
    mkdir -p packages/natives/native
    cp ${piNatives}/native/pi_natives.*.node packages/natives/native/ 2>/dev/null || true
    cp ${piNatives}/native/index.js packages/natives/native/ 2>/dev/null || true
    cp ${piNatives}/native/index.d.ts packages/natives/native/ 2>/dev/null || true
    cp ${piNatives}/native/loader-state.js packages/natives/native/ 2>/dev/null || true

    patchShebangs node_modules
    patchShebangs packages/*/node_modules 2>/dev/null || true
    patchShebangs packages/*/scripts/*.ts 2>/dev/null || true

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # 1. Stats client bundle (for omp-stats dashboard)
    bun --bun --cwd=packages/stats scripts/generate-client-bundle.ts --generate || true

    # 2. Docs index (for omp:// protocol)
    bun --bun --cwd=packages/coding-agent scripts/generate-docs-index.ts --generate || true

    # 3. Tool views (for HTML export) — needed by bundle-dist.ts step 4
    bun --bun --cwd=packages/collab-web run gen:tool-views || true

    # 4. Bundle dist/cli.js for the omp CLI entry (required for omp wrapper)
    bun --bun --cwd=packages/coding-agent scripts/bundle-dist.ts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install source tree
    mkdir -p $out/lib/oh-my-pi
    cp -R . $out/lib/oh-my-pi/
    chmod -R u+w $out/lib/oh-my-pi

    # Overlay node_modules from FOD (clean copy)
    rm -rf $out/lib/oh-my-pi/node_modules
    mkdir -p $out/lib/oh-my-pi/node_modules
    cp -R ${node_modules}/node_modules/. $out/lib/oh-my-pi/node_modules/
    chmod -R u+w $out/lib/oh-my-pi/node_modules
    # ── Prune musl sharp platform packages ──
    # `bun install --cpu="*" --os="*"` fetches every platform variant of
    # sharp, including the musl-libc builds. autoPatchelfHook then resolves
    # the NEEDED libvips-cpp.so of @img/sharp-linux-x64 to the *musl* copy
    # (its dir wins the search), rewriting the RUNPATH to the musl libvips.
    # On glibc hosts that dlopen fails with `libc.musl-x86_64.so.1: cannot
    # open shared object file`, which breaks any code path that loads sharp
    # (e.g. the local tiny-title worker → no session titles). Drop the musl
    # builds so autoPatchelfHook resolves to the glibc libvips instead.
    rm -rf $out/lib/oh-my-pi/node_modules/@img/sharp-libvips-linuxmusl-* \
           $out/lib/oh-my-pi/node_modules/@img/sharp-linuxmusl-*
    # ── Deduplicate libonnxruntime.so.1 SONAME ──
    # Multiple onnxruntime-node versions ship libonnxruntime.so.1 with
    # the same SONAME. The dynamic linker loads only the first one
    # encountered, which can mismatch the binding that needs a specific
    # version (e.g. VERS_1.24.3 vs VERS_1.26.0).
    # Fix: give each copy a unique SONAME and update all local NEEDED refs.
    for lib in $(find $out -name 'libonnxruntime.so.1' -type f 2>/dev/null); do
      dir=$(dirname "$lib")
      # Deterministic suffix from directory path
      suffix=$(echo "$dir" | cksum | cut -d' ' -f1)
      new_soname="libonnxruntime.so.1.$suffix"
      echo "Dedup SONAME: $lib → $new_soname"
      patchelf --set-soname "$new_soname" "$lib"
      # Rename the file to match the new SONAME, so the dynamic linker
      # can find it when searching RPATH directories by NEEDED name.
      mv "$lib" "$dir/$new_soname"
      lib="$dir/$new_soname"
      for elf in "$dir"/*; do
        [ -f "$elf" ] || continue
        patchelf --replace-needed libonnxruntime.so.1 "$new_soname" "$elf" 2>/dev/null || true
      done
    done

    # Overlay native addon from Rust build
    mkdir -p $out/lib/oh-my-pi/packages/natives/native
    cp ${piNatives}/native/pi_natives.*.node $out/lib/oh-my-pi/packages/natives/native/
    cp ${piNatives}/native/index.js $out/lib/oh-my-pi/packages/natives/native/
    cp ${piNatives}/native/index.d.ts $out/lib/oh-my-pi/packages/natives/native/
    cp ${piNatives}/native/loader-state.js $out/lib/oh-my-pi/packages/natives/native/

    # Expose @oh-my-pi/* packages for downstream consumers
    mkdir -p $out/lib/node_modules
    ln -s $out/lib/oh-my-pi/node_modules/@oh-my-pi $out/lib/node_modules/@oh-my-pi

    # ── omp wrapper ──
    mkdir -p $out/bin
    makeBinaryWrapper ${bun}/bin/bun $out/bin/omp \
      --argv0 omp \
      --add-flags "$out/lib/oh-my-pi/packages/coding-agent/dist/cli.js"

    # ── omp-stats wrapper ──
    makeBinaryWrapper ${bun}/bin/bun $out/bin/omp-stats \
      --argv0 omp-stats \
      --add-flags "$out/lib/oh-my-pi/packages/stats/src/index.ts"

    runHook postInstall
  '';

  # ── postFixup: add self-directory to RPATH after autoPatchelfHook ──
  # autoPatchelfHook replaces RPATH with Nix store paths only, stripping
  # $ORIGIN and non-store paths. The onnxruntime .node/.so pairs need to
  # find each other in the same directory. Using postPhases ensures this
  # runs AFTER fixupPhase (and thus after autoPatchelfHook).
  postPhases = [ "onnxRpathPhase" ];
  onnxRpathPhase = ''
    runHook preOnnxRpath
    for lib in $(find $out -name 'libonnxruntime.so.1.*' -type f 2>/dev/null); do
      dir=$(dirname "$lib")
      patchelf --add-rpath "$dir" "$lib" 2>/dev/null || true
      for elf in "$dir"/*; do
        [ -f "$elf" ] || continue
        patchelf --add-rpath "$dir" "$elf" 2>/dev/null || true
      done
    done
    runHook postOnnxRpath
  '';

  dontPatchElf = true;
  dontStrip = true;
  autoPatchelfIgnoreMissingDeps = [ "*" ];

  passthru = {
    inherit node_modules piNatives browserRelayExtension;
  };

  meta = {
    description = "The most capable agent surface that ships. Continuously tuned by real-world use — complete out of the box, open all the way down.";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
    ];
    mainProgram = "omp";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
