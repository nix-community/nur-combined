{
  lib,
  stdenv,
  stdenvNoCC,
  fetchFromGitHub,
  bun,
  writableTmpDirAsHomeHook,
  nodejs,
  rustPlatform,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook4,
  glib-networking,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
}:

let
  pname = "open-pencil";
  version = "0.13.2-unstable-2026-07-20";

  src = fetchFromGitHub {
    owner = "open-pencil";
    repo = "open-pencil";
    # The v0.13.2 tag predates required lockfile fixes.
    rev = "9db46f919b3e3905022e7e6a20a0092f1ba46efc";
    hash = "sha256-Pw8GgTbYwHlvjSWpS8IDIn+mIY4Y1uUJW5SPy0G77NU=";
  };

  nodeTargets = {
    aarch64-darwin = {
      cpu = "arm64";
      os = "darwin";
    };
    aarch64-linux = {
      cpu = "arm64";
      os = "linux";
    };
    x86_64-linux = {
      cpu = "x64";
      os = "linux";
    };
  };

  nodeModuleHashes = {
    aarch64-darwin = "sha256-v1pGloFe9D0RSOBRM/rx20sWEPUjvJS43HegrCVI958=";
    aarch64-linux = "sha256-XtgkatjpsayGoGIlFpLNrfOfKA48hL6IMPGeysklMBI=";
    x86_64-linux = "sha256-JyB2Jg0y2ejll2goTAve935tgmyD+NcKprgJrYWBDBs=";
  };

  system = stdenv.hostPlatform.system;
  nodeTarget =
    nodeTargets.${system} or {
      cpu = "unsupported";
      os = "unsupported";
    };

  nodeModules = stdenvNoCC.mkDerivation {
    pname = "open-pencil-node-modules";
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
    dontPatchShebangs = true;

    buildPhase = ''
      runHook preBuild

      export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
      bun install \
        --cpu="${nodeTarget.cpu}" \
        --force \
        --frozen-lockfile \
        --ignore-scripts \
        --linker=hoisted \
        --no-progress \
        --os="${nodeTarget.os}"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -R node_modules "$out"

      runHook postInstall
    '';

    outputHash = nodeModuleHashes.${system} or lib.fakeHash;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  configureNodeModules = ''
    cp -R ${nodeModules} node_modules
    chmod -R u+rw node_modules
    patchShebangs node_modules
    export HOME="$TMPDIR"
    export PATH="$PWD/node_modules/.bin:$PATH"
  '';
in
rustPlatform.buildRustPackage {
  inherit pname version src;

  cargoRoot = "desktop";
  buildAndTestSubdir = "desktop";
  cargoHash = "sha256-ZHlFcmTZ/2GbNxhrygmQBvlaFSWryO8o9tNXwVA8Q0Q=";

  nativeBuildInputs = [
    bun
    cargo-tauri.hook
    nodejs
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    libappindicatorSource="$(find "$cargoDepsCopy" \
      -type f \
      -path '*/libappindicator-sys-*/src/lib.rs' \
      -print \
      -quit)"

    if [[ -z "$libappindicatorSource" ]]; then
      echo "could not locate libappindicator-sys in $cargoDepsCopy" >&2
      exit 1
    fi

    substituteInPlace "$libappindicatorSource" \
      --replace-fail \
        "libayatana-appindicator3.so.1" \
        "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  postConfigure = configureNodeModules;

  tauriConf = builtins.toJSON {
    build.beforeBuildCommand = "bun run build:packages && bunx vite build";
    bundle = {
      createUpdaterArtifacts = false;
      macOS.signingIdentity = null;
    };
  };

  preBuild = ''
    tauriConfPath="$TMPDIR/tauri-nix.conf.json"
    printf '%s' "$tauriConf" > "$tauriConfPath"
    tauriBuildFlags+=(--config "$tauriConfPath")
  '';

  doCheck = false;

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(--set-default WEBKIT_DISABLE_DMABUF_RENDERER 1)
  '';

  meta = {
    description = "Open-source design editor";
    homepage = "https://openpencil.dev";
    license = lib.licenses.mit;
    mainProgram = "OpenPencil";
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # Precompiled CanvasKit WebAssembly
    ];
    maintainers = [
      {
        name = "Souheab";
        github = "Souheab";
        githubId = 85948717;
      }
    ];
    platforms = builtins.attrNames nodeTargets;
  };
}
