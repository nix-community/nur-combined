{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  mesa,
  glib,
  nspr,
  nss,
  dbus,
  atk,
  cups,
  cairo,
  gtk3,
  pango,
  xorg,
  expat,
  libxkbcommon,
  udev,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  libdrm,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "antigravity";
  version = "1.15.6-5250816192937984";

  # https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.13.3-4533425205018624/linux-x64/Antigravity.tar.gz
  src = fetchurl {
    url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${finalAttrs.version}/linux-x64/Antigravity.tar.gz";
    hash = "sha256-45mxPkttjsW1enRkeKh7D3ZS+KaQJP69TCXshHpMjqY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    glib
    nspr
    nss
    dbus
    atk
    cups
    cairo
    gtk3
    pango
    mesa
    expat
    libxkbcommon
    udev
    alsa-lib
    at-spi2-atk
    at-spi2-core
    libdrm
  ]
  ++ (with xorg; [
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxshmfence
    libxkbfile
  ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/antigravity
    cp -r * $out/share/antigravity

    mkdir -p $out/bin
    makeWrapper $out/share/antigravity/antigravity $out/bin/antigravity \
      --set ELECTRON_OZONE_PLATFORM_HINT auto \
      --add-flags "--enable-features=UseOzonePlatform --ozone-platform-hint=auto --enable-wayland-ime" \
      --unset NODE_OPTIONS \
      --set TMPDIR /tmp \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Google Antigravity — an internal Chrome/Electron-based development and onboarding tool";
    homepage = "https://research.google/";
    mainProgram = "antigravity";
    binaryNativeCode = true;
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
  };
})
