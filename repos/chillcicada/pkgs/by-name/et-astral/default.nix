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
  version = "2.1.111";

  src = builtins.fetchTarball {
    url = "https://github.com/ldoubil/astral/releases/download/v${finalAttrs.version}/astral-linux-x64.tar.gz";
    sha256 = "0q2as65574y2mznzm95685fr9yxvqcfscs6f35c5snlakpzcfvfh";
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

    mkdir -p $out/share/icons/hicolor/128x128/apps
    cp ${./assets/icons/astral.png} $out/share/icons/hicolor/128x128/apps/astral.png

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
