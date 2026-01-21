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
  nspr,
  nss,
  pango,
  libglvnd,
  mesa,
  vivaldi-ffmpeg-codecs,
  xorg,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "browser-115-bin";
  version = "36.0.0";

  src = fetchurl {
    url = "https://down.115.com/client/115pc/lin/115br_v${finalAttrs.version}.deb";
    hash = "sha256-E5+0421/SPHheTF+WtK9ixKHnnHTxP+Z2iaGVmG0/Eg=";
  };

  privacy = fetchurl {
    url = "https://115.com/privacy.html";
    hash = "sha256-E9H4Dd4CJLQ6iJGc6wJ++SeAvGFnLlYoL5/Tw2UiG6Y=";
  };

  copyright = fetchurl {
    url = "https://115.com/copyright.html";
    hash = "sha256-z+JeTV2CNrO2gIn7xLVqqn2x0KVgkF8frwBLxeRTQkU=";
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
    vivaldi-ffmpeg-codecs
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
    xorg.libXrender
    xorg.libXScrnSaver
    zlib
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    shopt -s nullglob
    for dir in usr opt; do
      if [ -e "$dir" ]; then
        cp -a "$dir" "$out/"
      fi
    done

    if [ -d "$out/usr/local/115Browser" ]; then
      mkdir -p "$out/opt/115"
      mv "$out/usr/local/115Browser" "$out/opt/115/"
      rmdir "$out/usr/local" 2>/dev/null || true
    fi

    substituteInPlace "$out/usr/share/applications/115Browser.desktop" \
      --replace-fail "/usr/local" "/opt/115"

    substituteInPlace "$out/opt/115/115Browser/115.sh" \
      --replace-fail "/usr/local" "/opt/115" \
      --replace-fail "/opt/115" "$out/opt/115"

    rm -f "$out/opt/115/115Browser/libEGL.so" "$out/opt/115/115Browser/libGLESv2.so"
    rm -f "$out/opt/115/115Browser/libvk_swiftshader.so" "$out/opt/115/115Browser/libvulkan.so.1"
    rm -f "$out/opt/115/115Browser/vk_swiftshader_icd.json"

    mkdir -p "$out/bin"
    makeWrapper "$out/opt/115/115Browser/115Browser" "$out/bin/115-browser" \
      --chdir "$out/opt/115/115Browser" \
      --prefix LD_LIBRARY_PATH : "$out/opt/115/115Browser" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}${
        lib.optionalString (stdenv.hostPlatform.is64bit) (
          ":" + lib.makeSearchPathOutput "lib" "lib64" finalAttrs.buildInputs
        )
      }" \
      --prefix XDG_DATA_DIRS : "${addDriverRunpath.driverLink}/share" \
      --add-flags "--disable-breakpad" \
      --add-flags "--disable-crashpad" \
      --add-flags "--disable-crash-reporter" \
      --add-flags "--disable-features=Crashpad" \
      --add-flags "--no-sandbox" \
      --add-flags "--disable-setuid-sandbox" \
      --add-flags "--disable-seccomp-filter-sandbox" \
      --add-flags "--use-gl=desktop" \
      --add-flags "--ozone-platform=x11" \
      --add-flags "--no-zygote" \
      --add-flags "--disable-gpu" \
      --add-flags "--disable-software-rasterizer"

    install -Dm644 "$privacy" "$out/share/licenses/${finalAttrs.pname}/privacy.html"
    install -Dm644 "$copyright" "$out/share/licenses/${finalAttrs.pname}/copyright.html"

    runHook postInstall
  '';

  dontStrip = true;

  postFixup = ''
    rpath="${lib.makeLibraryPath finalAttrs.buildInputs}${
      lib.optionalString (stdenv.hostPlatform.is64bit) (
        ":" + lib.makeSearchPathOutput "lib" "lib64" finalAttrs.buildInputs
      )
    }:${addDriverRunpath.driverLink}/lib"

    patchelf --set-rpath "$rpath" "$out/opt/115/115Browser/115Browser"
    patchelf --set-rpath "$rpath" "$out/opt/115/115Browser/chrome_crashpad_handler"
  '';

  meta = {
    description = "115 Browser";
    homepage = "https://115.com/product_browser";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "115-browser";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
