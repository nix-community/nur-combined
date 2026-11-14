{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  nodejs,
  rustPlatform,
  pkg-config,
  openssl,
  sqlite,
  oniguruma,
  onnxruntime,
  electron,
  makeWrapper,
  copyDesktopItems,
  autoPatchelfHook,
  makeDesktopItem,
  nix-update-script,
}:

let
  version = "1.4.7-beta.0";

  src = fetchFromGitHub {
    owner = "deta";
    repo = "surf";
    tag = version;
    hash = "sha256-UW85VCgjuPFajLPajJ0SgW3RJ57UrKQ/OuXHVCa3AbM=";
  };

  # Node addon (`@deta/backend`), loaded from the preload script as `index.node`
  backend = rustPlatform.buildRustPackage {
    pname = "deta-surf-backend";
    inherit version src;
    sourceRoot = "${src.name}/packages/backend";

    cargoHash = "sha256-Q350LqmHrZsFR8H/9qaCCb4LQouaIU1BlZ7TBhzazek=";

    nativeBuildInputs = [ pkg-config ];
    # Newer nixpkgs links libsqlite3-sys against the system library
    buildInputs = [
      openssl
      sqlite
    ];

    # Node picks the loader by the resolved file extension
    postInstall = ''
      mv $out/lib/libbackend.so $out/lib/index.node
    '';

    doCheck = false;
  };

  # Standalone `surf-backend` server (embeddings / vector search), spawned by the main process
  backend-server = rustPlatform.buildRustPackage {
    pname = "deta-surf-backend-server";
    inherit version src;
    sourceRoot = "${src.name}/packages/backend-server";

    cargoHash = "sha256-TuM9mR85mUmGjCVpEPjpcWW9gcuHDAnPOWN6H6Fa1H0=";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      openssl
      oniguruma # newer nixpkgs sets RUSTONIG_SYSTEM_LIBONIG
      onnxruntime
    ];

    env = {
      # Link against nixpkgs' onnxruntime instead of downloading prebuilt binaries
      ORT_STRATEGY = "system";
      ORT_LIB_LOCATION = "${lib.getLib onnxruntime}/lib";
      ORT_PREFER_DYNAMIC_LINK = "1";
    };

    doCheck = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "deta-surf";
  inherit version src;

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-RpNTVG9rBpVOrgFqEj9YbsRQMdVjWYQk7SiWIvwZQ0M=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    nodejs
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
  ];

  # For prebuilt native modules (sharp, @napi-rs/canvas)
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    SILENCE_WARNINGS = "true";
  };

  preBuild = ''
    # yarnConfigHook installs with --ignore-scripts, so apply upstream's patches manually
    node node_modules/patch-package/dist/index.js

    # yarnConfigHook only patches the root node_modules
    patchShebangs packages/*/node_modules app/node_modules
  '';

  buildPhase = ''
    runHook preBuild

    # Same order as the `build:app:frontend` turbo task
    yarn --offline workspace @deta/icons build
    yarn --offline workspace @deta/types build
    yarn --offline workspace @deta/utils build
    yarn --offline workspace @deta/services build
    yarn --offline workspace @deta/ui build:tailwind
    yarn --offline workspace @deta/ui build
    yarn --offline workspace @deta/dragcula build
    yarn --offline workspace @deta/editor build

    yarn --offline workspace desktop build

    # Everything except the runtime dependencies is bundled by electron-vite
    yarn install --offline --frozen-lockfile --ignore-scripts --production --no-progress --non-interactive

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appdir=$out/share/deta-surf
    mkdir -p $appdir

    # Symlinked, so autoPatchelf leaves it (and its RUNPATH) alone
    ln -s ${backend}/lib/index.node packages/backend/index.node
    rm -rf packages/backend/{src,target} packages/backend-server/{src,target}

    mkdir -p app/resources/bin
    ln -s ${backend-server}/bin/backend-server app/resources/bin/surf-backend

    cp -r package.json node_modules packages app $appdir/
    find $appdir -name .bin -type d -prune -exec rm -rf {} +
    # Prebuilt native modules for musl get installed too, but are unusable here
    find $appdir/node_modules -maxdepth 2 -type d -name '*-linuxmusl-*' -o -maxdepth 2 -type d -name '*-linux-*-musl' | xargs rm -rf

    # The app looks up unpacked resources at `<appPath>.unpacked` (normally `app.asar.unpacked`)
    ln -s app $appdir/app.unpacked

    install -Dm644 app/build/resources/prod/icon.png $out/share/icons/hicolor/512x512/apps/deta-surf.png

    makeWrapper ${lib.getExe electron} $out/bin/deta-surf \
      --add-flags $appdir/app \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --inherit-argv0

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "deta-surf";
      desktopName = "Surf";
      comment = finalAttrs.meta.description;
      exec = "deta-surf %U";
      icon = "deta-surf";
      categories = [ "Network" "WebBrowser" ];
      mimeTypes = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupWMClass = "Surf";
    })
  ];

  passthru = {
    inherit backend backend-server;
    updateScript = nix-update-script {
      extraArgs = [
        # Upstream only publishes `-beta.N` releases, skip the `.rc.N` pre-releases
        "--version=unstable"
        "--version-regex"
        "^(\\d+\\.\\d+\\.\\d+-beta\\.\\d+)$"
        "--subpackage"
        "backend"
        "--subpackage"
        "backend-server"
      ];
    };
  };

  meta = {
    description = "Personal AI notebooks: organize files & webpages and generate notes from them";
    homepage = "https://github.com/deta/surf";
    changelog = "https://github.com/deta/surf/releases/tag/${version}";
    license = lib.licenses.asl20;
    mainProgram = "deta-surf";
    platforms = lib.platforms.linux;
  };
})
