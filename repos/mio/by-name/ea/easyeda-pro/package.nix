{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  electron_36-bin,
}:

let
  version = "3.2.149";

  srcs = {
    x86_64-linux = fetchzip {
      url = "https://image.easyeda.com/files/easyeda-pro-linux-x64-${version}.zip";
      hash = "sha256-eTM0/bCdRGORkMkRp+q2ivGaOkTVnALyU2Bbt3j21js=";
      stripRoot = false;
    };
    aarch64-linux = fetchzip {
      url = "https://image.easyeda.com/files/easyeda-pro-linux-arm64-${version}.zip";
      hash = "sha256-SfwFupeHnRbtDq4SascNuUdMH63xedhdfuldkNqt5x4=";
      stripRoot = false;
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "easyeda-pro";
  inherit version;

  src =
    srcs.${stdenv.hostPlatform.system}
      or (throw "easyeda-pro: unsupported system ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install only the app resources (not the bundled Electron binary)
    mkdir -p $out/share/easyeda-pro
    cp -r easyeda-pro/resources $out/share/easyeda-pro/
    cp -r easyeda-pro/locales   $out/share/easyeda-pro/

    # Icons
    for size in 16 32 64 128 256 512; do
      if [ -f "easyeda-pro/icon/icon_''${size}x''${size}.png" ]; then
        install -Dm644 "easyeda-pro/icon/icon_''${size}x''${size}.png" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/easyeda-pro.png"
      fi
    done
    if [ -f "easyeda-pro/icon/icon_512x512@2x.png" ]; then
      install -Dm644 "easyeda-pro/icon/icon_512x512@2x.png" \
        "$out/share/icons/hicolor/1024x1024/apps/easyeda-pro.png"
    fi

    # Wrapper: use nixpkgs electron_36-bin to run the app
    mkdir -p $out/bin
    makeWrapper ${electron_36-bin}/bin/electron $out/bin/easyeda-pro \
      --add-flags "$out/share/easyeda-pro/resources/app" \
      --add-flags "--no-sandbox" \
      --add-flags "''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set-default FONTCONFIG_FILE /etc/fonts/fonts.conf

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "easyeda-pro";
      exec = "easyeda-pro %f";
      icon = "easyeda-pro";
      desktopName = "EasyEDA Pro";
      genericName = "PCB Design Tool";
      comment = "EasyEDA Professional Edition — schematic and PCB design";
      categories = [
        "Development"
        "Electronics"
        "Engineering"
      ];
      mimeTypes = [
        "application/eprj"
        "application/eprj2"
        "application/eprj3"
      ];
      keywords = [
        "PCB"
        "EDA"
        "Schematic"
        "JLCPCB"
      ];
      startupWMClass = "easyeda-pro";
    })
  ];

  meta = {
    description = "EasyEDA Professional Edition — schematic and PCB design tool by JLCPCB";
    longDescription = ''
      EasyEDA Pro is a powerful and free EDA tool for schematic capture, SPICE simulation,
      and PCB layout, developed by JLCPCB/LCSC. It supports full offline mode, hierarchical
      design, push routing, blind/buried vias, 3D shell design, and direct PCB ordering.
      Uses electron_36-bin (our vendored Electron 36, preserved from nixpkgs before removal).
    '';
    homepage = "https://pro.easyeda.com/";
    downloadPage = "https://easyeda.com/page/download";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    mainProgram = "easyeda-pro";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
