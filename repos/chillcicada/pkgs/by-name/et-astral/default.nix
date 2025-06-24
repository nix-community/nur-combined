{
  stdenv,
  lib,
  autoPatchelfHook,
  webkitgtk_4_1,
  libayatana-appindicator,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "et-astral";
  version = "2.1.3rc";

  src = builtins.fetchTarball {
    url = "https://github.com/chillcicada/easytier-astral/releases/download/v${finalAttrs.version}/astral-linux-x64.tar.gz";
    sha256 = "0a1fqliyswl66x71ilf4zl4i5mfaz9pkv8k4hrv83c95cmca91kn";
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
