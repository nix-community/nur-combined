{
  lib,
  stdenv,
  callPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  runCommand,
  buildNpmPackage,
  nix-update-script,
  nodejs_22,
  electron_41,
  makeShellWrapper,
  copyDesktopItems,
  makeDesktopItem,
  wrapGAppsHook3,
  gtk3,
  libxkbcommon,
  libx11,
  libxcb,
  libxtst,
}:

let
  electron = electron_41;
  nodejs = nodejs_22;
in
buildNpmPackage (finalAttrs: {
  pname = "waveterm";
  version = "0.14.5";

  src = fetchFromGitHub {
    owner = "wavetermdev";
    repo = "waveterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SUcvIpM+++qfyAlwUPSGVz2OUJXPe0bsefcjUKYUF/g=";
  };

  npmDepsHash = "sha256-YkRfTZwjIet6CWTtqG8X9LjoCOjHO+L2uHHtBlr7tao=";

  inherit nodejs;
  makeCacheWritable = true;

  # Native deps ship as prebuilt platform packages; rebuilding only pulls in the
  # docs workspace's old sharp, which tries to download libvips from the network.
  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    nodejs
    makeShellWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    libxkbcommon
    libx11
    libxcb
    libxtst
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    # postinstall runs `electron-builder install-app-deps`, which needs network.
    WAVETERM_SKIP_APP_DEPS = "1";
    # disable code signing on darwin
    CSC_IDENTITY_AUTO_DISCOVERY = "false";
  };

  dontNpmBuild = true;

  # Let the installPhase set up the electron wrapper itself.
  dontWrapGApps = true;

  # Running a shared electron against an app.asar leaves `app.isPackaged` false,
  # which would put Wave in "dev" mode (wrong data dir, dev features). This is a
  # production build, so force it.
  postPatch = ''
    substituteInPlace emain/emain-platform.ts \
      --replace-fail "const isDev = !app.isPackaged;" "const isDev = false;"
  '';

  buildPhase = ''
    runHook preBuild

    # 1. Build the renderer/main/preload bundles.
    npm run build:prod

    # 2. Build the tsunami frontend and assemble the runtime scaffold.
    pushd tsunami/frontend
    npm run build

    rm -rf scaffold
    mkdir -p scaffold
    cp ../templates/package.json.tmpl scaffold/package.json
    cp ${./tsunami-scaffold-package-lock.json} scaffold/package-lock.json

    scaffoldCache="$TMPDIR/scaffold-npm-cache"
    cp -r ${finalAttrs.passthru.scaffoldNpmDeps} "$scaffoldCache"
    chmod -R u+w "$scaffoldCache"

    pushd scaffold
    npmDeps="$scaffoldCache" "$prefetchNpmDeps" --fixup-lockfile package-lock.json
    npm_config_cache="$scaffoldCache" npm ci --offline --ignore-scripts
    popd

    mv scaffold/node_modules scaffold/nm
    cp -r dist scaffold/
    mkdir -p scaffold/dist/tw
    cp ../templates/*.go.tmpl scaffold/
    cp ../templates/tailwind.css scaffold/
    cp ../templates/gitignore.tmpl scaffold/.gitignore
    cp src/element/*.tsx scaffold/dist/tw/
    cp ../ui/*.go scaffold/dist/tw/
    cp ../engine/errcomponent.go scaffold/dist/tw/
    popd

    rm -rf dist/tsunamiscaffold
    cp -r tsunami/frontend/scaffold dist/tsunamiscaffold
    cp tsunami/templates/empty-gomod.tmpl dist/tsunamiscaffold/go.mod

    # 3. Drop in the schema and the Go binaries that electron-builder expects.
    rm -rf dist/schema
    cp -r schema dist/schema

    mkdir -p dist/bin
    cp -r ${finalAttrs.passthru.backend}/bin/. dist/bin/
    chmod -R u+w dist/bin

    # 4. Package the unpacked app directory against the nixpkgs electron.
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    node node_modules/electron-builder/out/cli/cli.js \
      --dir \
      -c electron-builder.config.cjs \
      -p never \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version} \
      -c.mac.identity=null \
      -c.npmRebuild=false

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    mkdir -p $out/share/waveterm
    cp -r make/*-unpacked/resources $out/share/waveterm/resources

    # use makeShellWrapper (instead of makeBinaryWrapper) for proper shell variable
    # expansion of the NIXOS_OZONE_WL flags, see https://github.com/NixOS/nixpkgs/issues/172583
    makeShellWrapper "${lib.getExe electron}" "$out/bin/waveterm" \
      --add-flags "$out/share/waveterm/resources/app.asar" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libxkbcommon
          libx11
          libxcb
          libxtst
        ]
      }" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    for size in 16 32 48 64 128 256 512; do
      install -Dm644 "build/icons/''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/waveterm.png"
    done
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications $out/bin
    cp -r make/*/Wave.app $out/Applications/Wave.app
    ln -s $out/Applications/Wave.app/Contents/MacOS/Wave $out/bin/waveterm
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = lib.optionals stdenv.hostPlatform.isLinux [
    (makeDesktopItem {
      name = "waveterm";
      exec = "waveterm %U";
      icon = "waveterm";
      desktopName = "Wave";
      genericName = "Terminal";
      comment = finalAttrs.meta.description;
      categories = [
        "Development"
        "Utility"
        "TerminalEmulator"
      ];
      keywords = [
        "developer"
        "terminal"
        "emulator"
      ];
      startupWMClass = "waveterm";
      terminal = false;
    })
  ];

  passthru = {
    backend = callPackage ./backend.nix {
      inherit (finalAttrs) version src;
    };
    scaffoldSrc = runCommand "waveterm-scaffold-src" { } ''
      mkdir -p $out
      cp ${./tsunami-scaffold-package.json} $out/package.json
      cp ${./tsunami-scaffold-package-lock.json} $out/package-lock.json
    '';
    scaffoldNpmDeps = fetchNpmDeps {
      name = "waveterm-tsunami-scaffold-npm-deps";
      src = finalAttrs.passthru.scaffoldSrc;
      hash = "sha256-PU6pKf+IlULH1JDjfCfeM2M+tEwPirr7zLlo9lTEtMU=";
    };
    # NOTE: a version bump also requires refreshing backend.nix's vendorHash and
    # regenerating tsunami-scaffold-package-lock.json from the new template.
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open-source, cross-platform terminal for seamless workflows";
    homepage = "https://www.waveterm.dev";
    downloadPage = "https://github.com/wavetermdev/waveterm/releases";
    changelog = "https://github.com/wavetermdev/waveterm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "waveterm";
    maintainers = with lib.maintainers; [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
