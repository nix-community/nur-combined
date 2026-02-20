{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "spflashtool6";
  version = "6.2228";

  src = pkgs.fetchzip {
    url = "https://spflashtools.com/wp-content/uploads/SP_Flash_Tool_v${version}_Linux.zip";
    sha256 = "sha256-UDLHA9MATJwMJ91/yqUnsC0+lhZNNsL5E/baT2YotTg=";
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "SP FlashTool 6";
    exec = "spflashtool6";
    icon = ../../share/icons/spflashtool6.png;
    comment = meta.description;
    desktopName = "SP FlashTool 6";
    genericName = "Mediatek FlashTool V6";
    categories = [
      "Development"
      "Engineering"
      "Utility"
    ];
    startupWMClass = "FlashTool";
  };
  desktopItems = [ desktopItem ];

  nativeBuildInputs = with pkgs; [
    unzip
    autoPatchelfHook
    libsForQt5.qt5.wrapQtAppsHook
    copyDesktopItems
  ];

  qtWrapperArgs =
    let
      runtimeLibs = with pkgs.libsForQt5.qt5; [
        qtbase
        qtserialport
        qtxmlpatterns
      ];
    in
    [
      "--set LD_LIBRARY_PATH ${pkgs.lib.makeLibraryPath runtimeLibs}"
      "--set QT_STYLE_OVERRIDE fusion"
    ];

  installPhase = ''
    runHook preInstall

    install -Dm0644 $src/{libflash,libimagechecker}.1.0.0.so \
      $src/libsla_challenge.so -t $out/lib/
    install -Dm0755 $src/SPFlashToolV6 $out/bin/spflashtool6

    runHook postInstall
  '';

  meta = {
    license = pkgs.lib.licenses.unfree;
    homepage = "https://spflashtools.com/linux/sp-flash-tool-v6-${version}-for-linux";
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    maintainers = [ "dmfrpro" ];
    description = "SP Flash Tool is an application to flash your MediaTek (MTK) SmartPhone";
    platforms = [ "x86_64-linux" ];
    mainProgram = "spflashtool6";
  };
}
