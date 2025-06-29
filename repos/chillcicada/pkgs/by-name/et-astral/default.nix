{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  webkitgtk_4_1,
  libayatana-appindicator,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "et-astral";
  version = "2.1.4";

  src = fetchurl {
    url = "https://github.com/ldoubil/astral/releases/download/v${finalAttrs.version}/astral-linux-x64.tar.gz";
    hash = "sha256-ZarMEnoYLATheC794atAKqv6D6RpIo5UTFOJzXPxvZw=";
  };

  stripRoot = false;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    webkitgtk_4_1
    libayatana-appindicator
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/app/astral
    cp -r . $out/app/astral

    mkdir -p $out/bin
    ln -s $out/app/astral/astral $out/bin/astral

    mkdir -p $out/share
    install -Dm0644 data/flutter_assets/assets/icon.ico \
      $out/share/icons/hicolor/64x64/apps/astral.png
    install -Dm0644 data/flutter_assets/assets/logo.png \
      $out/share/icons/hicolor/144x144/apps/astral.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "astral";
      exec = "sudo ${finalAttrs.meta.mainProgram} %u";
      desktopName = "Astral";
      genericName = "Network Traffic Manager";
      icon = "astral";
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "System"
        "Security"
      ];
      startupNotify = true;
      terminal = false;
      actions = {
        "start-monitor" = {
          name = "Start Monitor";
          exec = "sudo ${finalAttrs.meta.mainProgram} --monitor start %u";
        };
        "configure-rules" = {
          name = "Configure Rules";
          exec = "sudo ${finalAttrs.meta.mainProgram} --config rules %u";
        };
      };
    })
  ];

  meta = {
    description = "Decentralized Network Tool";
    license = lib.licenses.cc-by-nc-nd-40;
    homepage = "https://github.com/ldoubil/astral";
    mainProgram = "astral";
    platforms = lib.platforms.linux;
  };
})
