{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  electron,
  python3,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  fontconfig,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libkrb5,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxft,
  libxrandr,
  libxrender,
  libxcb,
  libxscrnsaver,
  libxtst,
  nspr,
  nss,
  pango,
  systemd,
  xdg-utils,
  commandLineArgs ? "",
  disableSandbox ? true,
  keepBundledRuntime ? true,
}:

let
  # Adapted from https://github.com/YeFaDa/workbuddy-nix.
  source =
    {
      x86_64-linux = {
        arch = "x64";
        hash = "sha256-74RoSYWCd4jSIO+c26PCll+aqjlyU1b3fH83tM2c9HU=";
      };
      aarch64-linux = {
        arch = "arm64";
        hash = "sha256-DWjogT1OqWms7T+mgSSmAjrXVtc+jLe+TxlayC1Buw8=";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported WorkBuddy platform");

  # The bundled 12.8.0 addon targets Electron 37. Version 13 uses N-API.
  betterSqlite3Src = fetchurl {
    url = "https://registry.npmjs.org/better-sqlite3/-/better-sqlite3-13.0.3.tgz";
    hash = "sha256-d+BRPcGkafs7zuxMf7WtP0AxCXh+2gW+BH7Bf9VoaMs=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "workbuddy";
  version = "5.5.6.38337834";

  src = fetchurl {
    url = "https://download.codebuddy.cn/workbuddy/saas/linux-${source.arch}-deb/WorkBuddy-linux-${source.arch}-deb-${finalAttrs.version}-5f969292.deb";
    # Use the actual file hash; the update API reports a different hash.
    hash = source.hash;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
    dpkg
    python3
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-core
    cairo
    cups
    fontconfig
    glib
    gtk3
    libdrm
    libgbm
    libGL
    libnotify
    libpulseaudio
    libsecret
    libuuid
    libxkbcommon
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxft
    libxrandr
    libxrender
    libxcb
    libxscrnsaver
    libxtst
    nspr
    nss
    pango
  ];

  runtimeDependencies = map lib.getLib [
    systemd
    libkrb5
  ];

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;
  dontWrapGApps = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/opt/WorkBuddy"
    mv opt/WorkBuddy/resources "$out/opt/WorkBuddy/"
    mv usr/share "$out/share"

    resources="$out/opt/WorkBuddy/resources"
    app="$resources/app.asar.unpacked"
    # Some unpacked entries in the ASAR header belong to other platforms
    # and are absent from the Linux deb. Extract all packed entries anyway.
    python3 ${./unpack-asar.py} "$resources/app.asar" "$app"
    rm "$resources/app.asar" "$resources/default_app.asar" "$resources/apparmor-profile"

    ${lib.optionalString (!keepBundledRuntime) ''
      rm -rf "$resources/runtime"
    ''}

    rm -rf "$app/node_modules/better-sqlite3"
    mkdir -p better-sqlite3
    tar xzf ${betterSqlite3Src} -C better-sqlite3
    mv better-sqlite3/package "$app/node_modules/better-sqlite3"
    find "$app/node_modules/better-sqlite3/prebuilds" -type f \
      ! -name 'linux-${source.arch}.node' -delete

    # Remove unused koffi variants so missing foreign libc dependencies
    # cannot hide a missing library in the native Linux runtime.
    find "$app/node_modules/koffi/build/koffi" -mindepth 1 -maxdepth 1 \
      -type d ! -name 'linux_${source.arch}' -exec rm -rf {} +

    find "$app" -type f \( -name '*.js' -o -name '*.cjs' -o -name '*.mjs' \) \
      -exec sed -i "s|process\\.resourcesPath|'$resources'|g" {} +

    substituteInPlace "$out/share/applications/workbuddy.desktop" \
      --replace-fail /opt/WorkBuddy/workbuddy "$out/bin/workbuddy"

    runHook postInstall
  '';

  postFixup = ''
    app="$out/opt/WorkBuddy/resources/app.asar.unpacked"
    # Wayland flags must expand when launched, so use a shell wrapper
    # even when wrapGAppsHook also brings in makeBinaryWrapper.
    makeShellWrapper ${lib.getExe electron} "$out/bin/workbuddy" \
      --argv0 workbuddy \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libuuid
          libsecret
          libxscrnsaver
          libxtst
        ]
      } \
      --add-flags "$app" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true --wayland-text-input-version=3}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --add-flags ${lib.escapeShellArg commandLineArgs} \
      ${lib.optionalString disableSandbox "--add-flags --no-sandbox"} \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "AI agent desktop application for office work";
    homepage = "https://www.workbuddy.cn/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "workbuddy";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
