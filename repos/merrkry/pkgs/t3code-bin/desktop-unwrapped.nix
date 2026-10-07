{
  lib,
  stdenv,
  appimageTools,
  autoPatchelfHook,
  makeShellWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-core,
  cups,
  dbus,
  desktop-file-utils,
  expat,
  gtk3,
  libgbm,
  libglvnd,
  libsecret,
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
  systemdLibs,
  wayland,
  xdg-utils,
  source,
  pname,
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  inherit pname;
  inherit (source) version src;

  contents = appimageTools.extract {
    inherit (finalAttrs) pname version src;
  };

  strictDeps = true;
  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeShellWrapper
    wrapGAppsHook3
  ];
  buildInputs = [
    alsa-lib
    at-spi2-core
    cups
    dbus
    expat
    gtk3
    libgbm
    libsecret
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
    stdenv.cc.cc.lib
    systemdLibs
  ];

  # These are loaded dynamically by Electron and native keyring modules.
  appendRunpaths = [
    (lib.makeLibraryPath [
      libsecret
      libglvnd
      wayland
    ])
  ];
  # Upstream also ships unused musl builds of its native modules.
  autoPatchelfIgnoreMissingDeps = [ "libc.musl-*.so.*" ];

  sourceRoot = "source";
  unpackPhase = ''
    runHook preUnpack
    cp -r ${finalAttrs.contents} "$sourceRoot"
    chmod -R u+w "$sourceRoot"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/t3code" "$out/bin"
    cp -a . "$out/libexec/t3code/"
    # Run Electron directly; AppRun exports bundled libraries to all children.
    rm -r "$out/libexec/t3code/usr" "$out/libexec/t3code/AppRun" \
      "$out/libexec/t3code/.DirIcon" "$out/libexec/t3code/t3code.png"

    install -Dm644 t3code.desktop "$out/share/applications/t3code.desktop"
    substituteInPlace "$out/share/applications/t3code.desktop" \
      --replace-fail 'Exec=AppRun' 'Exec=t3code-desktop'
    cp -a usr/share/icons "$out/share/"

    runHook postInstall
  '';

  postFixup = ''
    # Updates are managed through Nix; the extracted AppImage is immutable.
    makeShellWrapper "$out/libexec/t3code/t3code" "$out/bin/t3code-desktop" \
      --set T3CODE_DISABLE_AUTO_UPDATE true \
      --set-default APPIMAGE "$out/bin/t3code-desktop" \
      --prefix PATH : ${
        lib.escapeShellArg (
          lib.makeBinPath [
            desktop-file-utils
            xdg-utils
          ]
        )
      } \
      "''${gappsWrapperArgs[@]}"
  '';

  passthru = source;

  meta = {
    description = "Desktop interface for coding agents";
    homepage = "https://github.com/pingdotgg/t3code";
    changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ merrkry ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "t3code-desktop";
  };
})
