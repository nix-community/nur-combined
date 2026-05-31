{
  lib,
  stdenv,
  autoPatchelfHook,
  dpkg,
  fetchurl,
  makeBinaryWrapper,
  patchelf,
  addDriverRunpath,
  dbus,
  expat,
  glib,
  libidn2,
  alsa-lib,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  gdk-pixbuf,
  libgbm,
  libdrm,
  libxkbcommon,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxcursor,
  libxi,
  libxrender,
  libxscrnsaver,
  libXtst,
  gtk3,
  nspr,
  nss,
  pango,
  libglvnd,
  mesa,
  zlib,
  udev,
  systemd,
  fontconfig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "youku-bin";
  version = "1.0.0";

  src = fetchurl {
    url = "https://archive.kylinos.cn/kylin/partner/pool/youku-app_${finalAttrs.version}_amd64.deb";
    sha256 = "c28ade22d41fa6074fce7f2cb06f9db4dfba439698bbea37b0f5735d9ae30075";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeBinaryWrapper
    patchelf
  ];

  buildInputs = [
    dbus
    expat
    glib
    libidn2
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    gdk-pixbuf
    libgbm
    libdrm
    libxkbcommon
    nspr
    nss
    pango
    libglvnd
    mesa
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxcursor
    libxi
    libxrender
    libxscrnsaver
    libXtst
    gtk3
    zlib
    stdenv.cc.cc.lib
    systemd
    udev
    fontconfig
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/opt" "$out/share"

    # Copy from deb structure
    if [ -d "opt/优酷" ]; then
      cp -a "opt/优酷" "$out/opt/youku"
    fi
    if [ -d "usr/share" ]; then
      cp -a "usr/share/"* "$out/share/"
    fi

    # Fix desktop file
    if [ -f "$out/share/applications/YouKu.desktop" ]; then
      substituteInPlace "$out/share/applications/YouKu.desktop" \
        --replace-warn "/opt/优酷/YouKu" "youku" \
        --replace-warn "/opt/优酷/resources/assets/images/app_icon32.png" "youku" \
        --replace-warn "Categories=Viedo;" "Categories=AudioVideo;"
      
      mv "$out/share/applications/YouKu.desktop" "$out/share/applications/youku.desktop"
    fi

    # Create wrapper
    makeWrapper "$out/opt/youku/YouKu" "$out/bin/youku" \
      --chdir "$out/opt/youku" \
      --prefix LD_LIBRARY_PATH : "$out/opt/youku" \
      --prefix LD_LIBRARY_PATH : "$out/opt/youku/swiftshader" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}${
        lib.optionalString (stdenv.hostPlatform.is64bit) (
          ":" + lib.makeSearchPathOutput "lib" "lib64" finalAttrs.buildInputs
        )
      }" \
      --prefix XDG_DATA_DIRS : "${addDriverRunpath.driverLink}/share" \
      --add-flags "--no-sandbox"

    # Install icons (using standard sizes if available)
    for size in 16 32 64 128 256 512; do
      if [ -f "$out/share/icons/hicolor/''${size}x''${size}/apps/YouKu.png" ]; then
        mv "$out/share/icons/hicolor/''${size}x''${size}/apps/YouKu.png" "$out/share/icons/hicolor/''${size}x''${size}/apps/youku.png"
      fi
    done

    # Fallback: copy icon from app resources if not in hicolor
    if [ -f "$out/opt/youku/resources/assets/images/app_icon256.png" ]; then
      install -Dm644 "$out/opt/youku/resources/assets/images/app_icon256.png" "$out/share/pixmaps/youku.png"
    elif [ -f "$out/opt/youku/resources/assets/images/app_icon32.png" ]; then
      install -Dm644 "$out/opt/youku/resources/assets/images/app_icon32.png" "$out/share/pixmaps/youku.png"
    fi

    # Remove conflicting swiftshader bundled libraries if needed, though electron usually prefers its own unless stripped.
    # autoPatchelfHook will handle patching the bundled electron binaries.

    runHook postInstall
  '';

  dontStrip = true;

  meta = {
    description = "Linux version of the Youku client APP, implemented on UOS using Electron technology";
    homepage = "https://www.youku.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "youku";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
