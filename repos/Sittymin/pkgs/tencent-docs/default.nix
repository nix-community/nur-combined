{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  patchelf,
  makeShellWrapper,
  wrapGAppsHook3,
  copyDesktopItems,

  alsa-lib,
  at-spi2-core,
  atk,
  at-spi2-atk,
  cairo,
  curl,
  cups,
  dbus,
  expat,
  fontconfig,
  glib,
  gtk3,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXi,
  libXrandr,
  libXtst,
  libgbm,
  libglvnd,
  libxkbcommon,
  libxcb,
  mesa,
  nspr,
  nss,
  pango,
  udev,
  wayland,
  xkeyboard-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tencent-docs";
  version = "3.12.4";

  src = fetchurl {
    url = "https://desktop-gz.docs.qq.com/Installer/30001/3.12.4/TencentDocs-x64.deb?sign=6b659c9a2a54ec504ec73dfd31ce058f&t=1788843580&response-content-disposition=attachment%3Bfilename%3D%22TencentDocs-x64.deb%22%3Bfilename%2A%3DUTF-8%27%27TencentDocs-x64.deb";
    hash = "sha256-KbDNAmPi+MDO0ISqvyUkAFlx1FSDB53W38HdeMaho/U=";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    dpkg
    patchelf
    makeShellWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    atk
    at-spi2-atk
    cairo
    curl
    cups
    dbus
    expat
    fontconfig
    glib
    gtk3
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXtst
    libgbm
    libglvnd
    libxkbcommon
    libxcb
    mesa
    nspr
    nss
    pango
    udev
    wayland
    xkeyboard-config
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/libexec/腾讯文档"
    cp -r "opt/腾讯文档/"* "$out/libexec/腾讯文档/"
    mkdir -p "$out/share"
    cp -r usr/share/* "$out/share/"

    install -Dm644 "opt/腾讯文档/resources/icon.png" \
      "$out/share/icons/hicolor/512x512/apps/tdappdesktop.png"

    # Editor SDK: code looks at <app>/Helpers/editor-sdk/editor_sdk
    # but it's actually in app.asar.unpacked/node_modules/@tencent/tencent-docs-ai-engine/bin/linux-x64/
    local sdkSrc="$out/libexec/腾讯文档/resources/app.asar.unpacked/node_modules/@tencent/tencent-docs-ai-engine/bin/linux-x64"
    mkdir -p "$out/libexec/腾讯文档/Helpers/editor-sdk"
    ln -s "$sdkSrc/editor_sdk" "$out/libexec/腾讯文档/Helpers/editor-sdk/editor_sdk"
    ln -s "$sdkSrc/.editor-sdk-version" "$out/libexec/腾讯文档/Helpers/editor-sdk/.editor-sdk-version"
    ln -s "$sdkSrc/editor-sdk-host.json" "$out/libexec/腾讯文档/Helpers/editor-sdk/editor-sdk-host.json"

    runHook postInstall
  '';

  dontPatchELF = true;
  dontWrapGApps = true;

  preFixup = let
    libPath = lib.makeLibraryPath [
      alsa-lib at-spi2-core atk at-spi2-atk cairo curl cups dbus
      expat fontconfig glib gtk3 pango
      libX11 libXcomposite libXdamage libXext libXfixes
      libXi libXrandr libXtst libgbm libglvnd libxkbcommon libxcb
      mesa nspr nss udev wayland
    ];
    appLib = "$out/libexec/腾讯文档";
  in ''
    patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
      --set-rpath "${appLib}:${libPath}" \
      "$out/libexec/腾讯文档/tdappdesktop"

    # Editor SDK binary also needs patching
    patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
      --set-rpath "${appLib}:${libPath}" \
      "$out/libexec/腾讯文档/resources/app.asar.unpacked/node_modules/@tencent/tencent-docs-ai-engine/bin/linux-x64/editor_sdk" || true

    makeShellWrapper "$out/libexec/腾讯文档/tdappdesktop" "$out/bin/tencent-docs" \
      --set LD_LIBRARY_PATH "${appLib}:${libPath}" \
      --set XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb" \
      --set XLOCALEDIR "${libX11}/share/X11/locale" \
      --add-flags "--no-sandbox" \
      --add-flags "\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}"
  '';

  meta = {
    description = "Tencent Docs (腾讯文档) desktop client";
    homepage = "https://docs.qq.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "tencent-docs";
    maintainers = [ ];
  };
})
