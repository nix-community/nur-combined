{
  lib,
  stdenv,
  stdenvNoCC,
  callPackage,
  fetchurl,

  # hooks
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,

  # native build inputs
  dpkg,
  unzip,

  # build inputs
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  dconf,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libgbm,
  libnotify,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  qt6,
  systemdLibs,

  # runtime deps
  libGL,
  libpulseaudio,
  libsecret,
  nodejs-slim,
  pipewire,
  ripgrep,
  tectonic-unwrapped,
  vulkan-loader,
  xdg-utils,

  codexPackage ? null,
}:
let
  inherit (stdenvNoCC.hostPlatform) isLinux isDarwin system;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "chatgpt";
  inherit (finalAttrs.passthru.source) version;

  src = fetchurl finalAttrs.passthru.source.src;

  strictDeps = true;
  __structuredAttrs = true;

  # autoPatchelf moves PT_INTERP beyond detect-libc's 2 KiB scan. Its
  # process.report fallback trips Electron's CFI, so use the glibc watcher.
  postPatch = lib.optionalString isLinux ''
    sed -i "s|const family = familySync();|const family = 'glibc'     ;|" usr/lib/chatgpt/resources/app.asar
  '';

  nativeBuildInputs =
    lib.optionals isDarwin [ unzip ]
    ++ lib.optionals isLinux [
      autoPatchelfHook
      dpkg
      makeWrapper
      qt6.wrapQtAppsHook
      wrapGAppsHook3
    ];

  buildInputs = lib.optionals isLinux [
    (lib.getLib stdenv.cc.cc)
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dconf
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libgbm
    libnotify
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    qt6.qtbase
    systemdLibs
  ];

  dontWrapGApps = true;
  dontWrapQtApps = true;

  sourceRoot = if isLinux then "root" else ".";

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString isDarwin ''
    mkdir -p "$out/Applications"
    mkdir -p "$out/bin"
    cp -a ChatGPT.app "$out/Applications"
    ln -s "$out/Applications/ChatGPT.app/Contents/MacOS/ChatGPT" "$out/bin/ChatGPT"
  ''
  + lib.optionalString isLinux ''
    mkdir -p "$out"
    cp -r usr/* "$out"

    # Remove the unused Qt 5 fallback shim.
    rm -f "$out/lib/chatgpt/libqt5_shim.so"

    # This glibc desktop package uses neither musl nor Android variants.
    rm -f \
      "$out/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/node_modules/@worklouder/wl-device-kit/node_modules/serialport/node_modules/@serialport/bindings-cpp/prebuilds/"{linux-*/node.napi.musl.node,android-*/node.napi.*.node} \
      "$out/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/node_modules/@worklouder/wl-device-kit/node_modules/node-hid/prebuilds/"{HID,HID_hidraw}-linux-*-musl/node-napi-v4.node \
      "$out/lib/chatgpt/resources/plugins/openai-bundled/plugins/"{browser,chrome}"/scripts/node_modules/classic-level/prebuilds/"{linux-*/classic-level.musl.node,android-*/classic-level.*.node}

    ln -sf ${lib.getExe tectonic-unwrapped} "$out/lib/chatgpt/resources/plugins/openai-bundled/plugins/latex/bin/tectonic"
    ln -sf ${lib.getExe ripgrep} "$out/lib/chatgpt/resources/rg"
    ln -sf ${lib.getExe nodejs-slim} "$out/lib/chatgpt/resources/cua_node/bin/node"

    install -Dm755 ${lib.getExe finalAttrs.passthru.launcher} "$out/bin/chatgpt"
  ''
  + lib.optionalString (isLinux && codexPackage != null) ''
    ln -sf ${lib.getExe codexPackage} "$out/lib/chatgpt/resources/codex"
    ln -sf ${codexPackage}/bin/codex-code-mode-host "$out/lib/chatgpt/resources/codex-code-mode-host"
  ''
  + ''
    runHook postInstall
  '';

  postFixup = lib.optionalString isLinux ''
    wrapProgram "$out/bin/chatgpt" \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --set CHATGPT_EXECUTABLE "$out/lib/chatgpt/ChatGPT" \
      --set CHATGPT_RESOURCES_SOURCE "$out/lib/chatgpt/resources" \
      --set CHATGPT_RESOURCES_CACHE_KEY ${lib.escapeShellArg "${finalAttrs.version}-${system}"} \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs-slim
          xdg-utils
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libnotify
          libpulseaudio
          libsecret
          pipewire
          vulkan-loader
        ]
      } \
      --set-default CODEX_BROWSER_USE_NODE_PATH ${lib.getExe nodejs-slim} \
      --set-default NODE_REPL_NODE_PATH ${lib.getExe nodejs-slim} \
      ${lib.escapeShellArgs (
        lib.optionals (codexPackage != null) [
          "--set-default"
          "CODEX_CLI_PATH"
          (lib.getExe codexPackage)
        ]
      )}
  '';

  dontStrip = true;

  passthru = {
    updateScript = ./update.sh;
    sources = import ./source.nix;
    source = finalAttrs.passthru.sources.${system} or (throw "chatgpt is not supported on ${system}");
    launcher = callPackage ./launcher.nix { };
  };

  meta = {
    description = "Desktop application for ChatGPT";
    homepage = "https://openai.com/chatgpt/desktop/";
    changelog = "https://learn.chatgpt.com/docs/changelog";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      wattmto
      moraxyc
    ];
    platforms = lib.attrNames finalAttrs.passthru.sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = if isDarwin then "ChatGPT" else "chatgpt";
  };
})
