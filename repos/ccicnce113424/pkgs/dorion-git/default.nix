{
  lib,
  autoPatchelfHook,
  rustPlatform,
  fetchPnpmDeps,
  pnpm_11,
  pnpmConfigHook,
  cargo-tauri,
  cef-binary,
  cmake,
  ninja,
  copyDesktopItems,
  gtk3,
  libayatana-appindicator,
  libX11,
  libXcursor,
  libXi,
  libxcb,
  librsvg,
  libxkbcommon,
  makeDesktopItem,
  wayland,
  webkitgtk_4_1,
  zstd,
  nodejs,
  openssl,
  pkg-config,
  shelter,
  wrapGAppsHook3,
  yq-go,
  sources,
  hash,
  upstreamVersion,
  cefInfo,
}:
let
  desktopItem = makeDesktopItem {
    name = "Dorion";
    desktopName = "Dorion";
    comment = "Tiny alternative Discord client";
    exec = "Dorion %U";
    icon = "Dorion";
    tryExec = "Dorion";
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
    ];
    keywords = [
      "dorion"
      "discord"
      "vencord"
      "chat"
      "im"
      "vc"
      "ds"
      "dc"
      "dsc"
      "tauri"
    ];
    mimeTypes = [ "x-scheme-handler/discord" ];
    startupNotify = true;
    startupWMClass = "Dorion";
    terminal = false;
  };

  # Upstream switched the Linux runtime from WebKitGTK to CEF, so the app now
  # links `libcef` through `tauri-runtime-cef` instead of `wry`/WebKitGTK.
  #
  # CEF derives its resource directory (`*.pak`, `icudtl.dat`, `locales/`) from
  # the path the loader mapped `libcef.so` from, so the archive's
  # `Release/` + `Resources/` split has to be flattened into one directory.
  # Moving instead of copying avoids a second 436 MB copy of the library.
  cef =
    (cef-binary.override {
      version = cefInfo.version;
      gitRevision = cefInfo.gitRevision;
      chromiumVersion = cefInfo.chromiumVersion;
      srcHashes = {
        x86_64-linux = cefInfo.sha256;
      };
    }).overrideAttrs
      (prev: {
        stripDebugList = [ "lib" ];

        postInstall = (prev.postInstall or "") + ''
          mkdir -p $out/lib/locales
          mv Release/* $out/lib/
          mv Resources/locales/* $out/lib/locales/
          mv Resources/*.pak Resources/icudtl.dat $out/lib/
          mv CMakeLists.txt cmake include libcef_dll CREDITS.html $out/lib/
          rm -rf Release Resources
          # Upstream only ships the locale CEF actually loads.
          find $out/lib/locales -type f ! -name 'en-US.pak' -delete
          printf '%s\n' '{"type":"minimal","name":"${cefInfo.archiveName}","sha1":"${cefInfo.archiveSha1}"}' >$out/lib/archive.json
        '';
      });
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources) pname src;
  version = "${upstreamVersion}-unstable-${sources.date}";

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoDeps = rustPlatform.importCargoLock sources.cargoLock."src-tauri/Cargo.lock";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit hash;
    pnpm = pnpm_11;
    fetcherVersion = 4;
  };

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoPatchelfHook
    pnpmConfigHook
    pnpm_11
    cargo-tauri.hook
    nodejs
    pkg-config
    yq-go
    wrapGAppsHook3
    copyDesktopItems
    # `cef-dll-sys` compiles CEF's `libcef_dll_wrapper` against the headers.
    cmake
    ninja
  ];

  # `winit` resolves these with dlopen() at run time, so they are not link
  # dependencies; `autoPatchelfHook` still has to put them on the RUNPATH.
  # `libappindicator-sys` dlopen()s the tray library at run time.
  runtimeDependencies = [
    libayatana-appindicator
    libxkbcommon
    libX11
    libXcursor
    libXi
    wayland
  ];

  buildInputs = [
    openssl
    gtk3
    # The tauri CLI probes this with pkg-config while bundling.
    libayatana-appindicator
    # Tauri's `wry` feature stays enabled through the plugins' default
    # features even though the app runs on `CefRuntime`.
    webkitgtk_4_1
    libxcb
    librsvg
    zstd
    cef
  ];

  env = {
    CI = "true";
    TAURI_RESOURCE_DIR = "${placeholder "out"}/lib";
    CEF_PATH = "${cef}/lib";
  };

  desktopItems = [ desktopItem ];

  postPatch = ''
    # remove updater
    rm -rf updater

    # disable auto-updater
    yq -iPo=json '
      .bundle.resources = (.bundle.resources | map(select(. != "updater*")))
    ' src-tauri/tauri.conf.json

    # CEF is installed from the nix store (see postInstall) instead of letting
    # `scripts/bundle-cef.sh` stage `src-tauri/target` into the deb.
    yq -iPo=json '
      del(.build.beforeBundleCommand) |
      del(.bundle.linux.deb.files) |
      del(.bundle.linux.rpm.files)
    ' src-tauri/tauri.linux.conf.json

    # link shelter injection
    ln -s ${shelter}/shelter.js src-tauri/injection/shelter.js

    # link html/frontend data
    ln -s "$(pwd)/src" src-tauri/html
  '';

  preFixup = ''
    # Dorion re-execs itself with `--no-sandbox`, using `current_exe()` as the
    # new `argv[0]`; winit derives the X11 `WM_CLASS` from `argv[0]`, which
    # would end up as `.Dorion-wrapped` and stop `StartupWMClass` from matching.
    # Handing the switch to the wrapper skips that re-exec and pins the class.
    gappsWrapperArgs+=(
      --add-flags --no-sandbox
      --argv0 Dorion
    )
  '';

  postInstall = ''
    mkdir -p "$out/lib/Dorion"
    ln -s "$out/lib/Dorion" "$out/lib/dorion"
    rm -rf "$out/lib/Dorion/injection"
    cp -r src-tauri/injection "$out/lib/Dorion"
    cp -r src "$out/lib/Dorion"

    # The bundled desktop file is replaced by `desktopItem`.
    rm -rf "$out/share/applications"
  '';

  # error: failed to run custom build command for `Dorion v6.5.3 (/build/source/src-tauri)`
  # Permission denied (os error 13)
  doCheck = false;

  passthru.updateScript = [ ./update.sh ];

  meta = {
    homepage = "https://spikehd.github.io/projects/dorion/";
    description = "Tiny alternative Discord client";
    longDescription = ''
      Dorion is an alternative Discord client aimed towards lower-spec or
      storage-sensitive PCs that supports themes, plugins, and more!
    '';
    changelog = "https://github.com/SpikeHD/Dorion/releases";
    downloadPage = "https://github.com/SpikeHD/Dorion/releases";
    license = lib.licenses.gpl3Only;
    mainProgram = "Dorion";
    maintainers = with lib.maintainers; [
      nyabinary
      aleksana
      griffi-gh
      getchoo
    ];
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
