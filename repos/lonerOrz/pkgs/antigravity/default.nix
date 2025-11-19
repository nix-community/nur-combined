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
  version = "1.11.2-6251250307170304";

  src = fetchurl {
    url = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${finalAttrs.version}/linux-x64/Antigravity.tar.gz";
    hash = "sha256-0bERWudsJ1w3bqZg4eTS3CDrPnLWogawllBblEpfZLc=";
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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"

    runHook postInstall
  '';

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
