# Almost copy-pasted from MordragT repo
# https://github.com/MordragT/nixos/blob/master/pkgs/by-name/spflashtool/default.nix

{
  stdenv,
  lib,
  fetchzip,
  libsForQt5,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  ...
}:

stdenv.mkDerivation rec {
  name = "spflashtool6";
  version = "6.2228";

  src = fetchzip {
    url = "https://spflashtools.com/wp-content/uploads/SP_Flash_Tool_v${version}_Linux.zip";
    sha256 = "sha256-UDLHA9MATJwMJ91/yqUnsC0+lhZNNsL5E/baT2YotTg=";
  };

  desktopItem = makeDesktopItem {
    name = "SP FlashTool 6";
    exec = "spflashtool6";
    icon = ../../share/icons/spflashtool6.png;
    comment = meta.description;
    desktopName = "SP FlashTool 6";
    genericName = "Mediatek FlashTool V6";
    categories = [ "Development" "Engineering" "Utility" ];
    startupWMClass = "FlashTool";
  };
  desktopItems = [ desktopItem ];


  nativeBuildInputs = [
    autoPatchelfHook
    libsForQt5.qt5.wrapQtAppsHook
    copyDesktopItems
  ];

  qtWrapperArgs = let
    runtimeLibs = with libsForQt5.qt5; [
      qtbase
      qtserialport
      qtxmlpatterns
    ];
  in "--set LD_LIBRARY_PATH ${lib.makeLibraryPath runtimeLibs}";

  installPhase = ''
    runHook preInstall

    install -Dm0644 $src/libflash.1.0.0.so $out/lib/libflash.1.0.0.so
    install -Dm0644 $src/libimagechecker.1.0.0.so $out/lib/libimagechecker.1.0.0.so
    install -Dm0644 $src/libsla_challenge.so $out/lib/libsla_challenge.so

    install -Dm0755 $src/SPFlashToolV6 $out/bin/spflashtool6

    runHook postInstall
  '';

  meta = {
    license = lib.licenses.unfree;
    homepage = "https://spflashtools.com/linux/sp-flash-tool-v6-2228-for-linux";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    description = "SP Flash Tool is an application to flash your MediaTek (MTK) SmartPhone.";
    platforms = [ "x86_64-linux" ];
    mainProgram = "spflashtool6";
  };
}
