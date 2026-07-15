{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  rustPlatform,
  makeBinaryWrapper,
  writableTmpDirAsHomeHook,
  nodejs,
  pkg-config,
  wayland,
  libxcb,
}:

let
  version = "16.5.2";
  pname = "oh-my-pi";

  src = fetchFromGitHub {
    owner = "can1357";
    repo = "oh-my-pi";
    rev = "v${version}";
    hash = "sha256-eOFdTU4Vcv5PXYEeAgO1rXho2eEkWQrWCZ0pCaUjLro=";
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
        --cpu="*" \
        --os="*" \
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

    outputHash = "sha256-5DnRl5utPTknQbugJMEjbG4qvuDASxltx1Uh0D2aNyE=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  # ─────────────────────────────────────────────────
  # Phase 2: Rust native addon
  # ─────────────────────────────────────────────────
  piNatives = rustPlatform.buildRustPackage {
    pname = "${pname}-pi-natives";
    inherit version src;

    cargoHash = "sha256-gcUxTcbLRmGyvT/iXyfxRoRRkP4WbVe6yQiYq+fx+O4=";

    nativeBuildInputs = [
      bun
      pkg-config
      nodejs
    ];

    buildInputs = [
      wayland
      libxcb
    ];

    RUSTC_BOOTSTRAP = "1";

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

    buildPhase = ''
      runHook preBuild
      bun --bun --cwd=packages/natives run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/native"
      cp -vr packages/natives/native/*.node "$out/native/" 2>/dev/null || true
      cp -vr packages/natives/native/*.js "$out/native/" 2>/dev/null || true
      cp -vr packages/natives/native/*.d.ts "$out/native/" 2>/dev/null || true
      runHook postInstall
    '';

    dontStrip = true;

    meta = {
      description = "Native Rust addon for oh-my-pi";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version src;

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    bun
    nodejs
    makeBinaryWrapper
    writableTmpDirAsHomeHook
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

  dontFixup = true;

  passthru = {
    inherit node_modules piNatives;
  };

  meta = {
    description = "AI coding agent CLI/TUI with 32 built-in tools, 40+ LLM providers, and sub-agent orchestration";
    homepage = "https://github.com/can1357/oh-my-pi";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "omp";
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
