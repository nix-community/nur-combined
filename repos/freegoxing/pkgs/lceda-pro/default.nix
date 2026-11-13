{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  makeDesktopItem,
  alsa-lib,
  atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libglvnd,
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
  systemd,
}:
let
  desktopItem = makeDesktopItem {
    name = "lceda-pro";
    desktopName = "嘉立创EDA专业版";
    exec = "lceda-pro %U";
    icon = "lceda-pro";
    categories = [
      "Electronics"
      "Engineering"
    ];
    startupWMClass = "lceda-pro";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lceda-pro";
  version = "4.1.99";

  src = fetchurl {
    url = "https://image.lceda.cn/files/lceda-pro-linux-x64-${finalAttrs.version}.zip";
    hash = "sha256-wZEuIL8wniGyz0cfmHMFlY6quu1S3iNs3dpZFAzdO7I=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [
    alsa-lib
    atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
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
    systemd
    stdenv.cc.cc.lib
  ];
  sourceRoot = ".";
  unpackPhase = ''
    runHook preUnpack
    # The upstream ZIP has a filename encoding mismatch; unzip reports it as a warning.
    unzip -q "$src" || [ "$?" -eq 1 ]
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/opt/lceda-pro" "$out/bin" "$out/share/applications"
    cp -r lceda-pro/. "$out/opt/lceda-pro/"
    makeWrapper "$out/opt/lceda-pro/lceda-pro" "$out/bin/lceda-pro" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}"
    cp ${desktopItem}/share/applications/*.desktop "$out/share/applications/"
    for size in 16 24 32 48 64 96 128 256 512; do
      install -Dm644 "lceda-pro/icon/icon_''${size}x''${size}.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/lceda-pro.png"
    done
    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    description = "LCEDA Pro electronics design automation client";
    homepage = "https://lceda.cn/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "lceda-pro";
  };
})
