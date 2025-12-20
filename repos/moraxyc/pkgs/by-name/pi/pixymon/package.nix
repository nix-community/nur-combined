{
  lib,
  stdenv,
  sources,
  pkg-config,
  makeDesktopItem,
  copyDesktopItems,
  libsForQt5,
  libusb1,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixymon";
  inherit (sources.pixy2) src version;

  sourceRoot = "${finalAttrs.src.name}/src/host/pixymon";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libusb1
  ];

  postPatch = ''
    substituteInPlace pixymon.pro \
      --replace "INCLUDEPATH += /usr/include/libusb-1.0" "" \
      --replace "LIBS += -lusb-1.0" ""

    echo "CONFIG += link_pkgconfig" >> pixymon.pro
  '';

  # Copied from aur pixymon-git
  desktopItems = [
    (makeDesktopItem {
      name = "pixymon";
      desktopName = "PixyMon";
      genericName = "Pixy2 Configuration Utility";
      exec = "PixyMon";
      icon = "pixymon";
      terminal = false;
      comment = "Configuration utility for Pixy2 camera";
      categories = [
        "Development"
        "Education"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 PixyMon $out/bin/PixyMon
    install -Dm644 pixyflash.bin.hdr $out/bin/pixyflash.bin.hdr
    install -Dm644 ../linux/pixy.rules $out/lib/udev/rules.d/99-pixy.rules
    install -Dm644 icons/pixy.png $out/share/pixmaps/pixymon.png

    runHook postInstall
  '';

  meta = {
    description = "Configuration utility for Pixy2 camera";
    homepage = "https://pixycam.com";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "PixyMon";
  };
})
