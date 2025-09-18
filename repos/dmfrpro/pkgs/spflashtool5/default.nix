# Previous work was done by MordragT
# This package fixes appearance of config files in PATH
# and additionally configures readback by scatter
# https://github.com/MordragT/nixos/blob/master/pkgs/by-name/spflashtool-v5/default.nix

{
  pkgs,
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  fontconfig,
  freetype,
  glib,
  xorg,
  zlib,
  ...
}:

stdenv.mkDerivation rec {
  name = "spflashtool5";
  version = "5.2228";

  src = fetchzip {
    url = "https://spflashtools.com/wp-content/uploads/SP_Flash_Tool_v${version}_Linux.zip";
    sha256 = "sha256-QZYltrfb7Sp+rmNfqgffKfbvBKlF8q0KhUnUyxaafFI=";
  };

  desktopItem = makeDesktopItem {
    name = "SP FlashTool 5";
    exec = "spflashtool5";
    icon = ../../share/icons/spflashtool5.png;
    comment = meta.description;
    desktopName = "SP FlashTool 5";
    genericName = "Mediatek FlashTool V5";
    categories = [ "Development" "Engineering" "Utility" ];
    startupWMClass = "FlashTool";
  };
  desktopItems = [ desktopItem ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    fontconfig
    freetype
    glib
    xorg.libXrender
    xorg.libXext
    xorg.libX11
    xorg.libSM
    xorg.libICE
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/spflashtool5/lib $out/bin
    cp -r $src/lib/pkgconfig $out/opt/spflashtool5/lib/pkgconfig

    install -Dm0644 $src/lib/lib* $out/opt/spflashtool5/lib
    install -Dm0644 $src/libflashtool.so $out/opt/spflashtool5/lib/libflashtool.so
    install -Dm0644 $src/libflashtool.v1.so $out/opt/spflashtool5/lib/libflashtool.v1.so
    install -Dm0644 $src/libflashtoolEx.so $out/opt/spflashtool5/lib/libflashtoolEx.so
    install -Dm0644 $src/libsla_challenge.so $out/opt/spflashtool5/lib/libsla_challenge.so
    install -Dm0644 $src/MTK_AllInOne_DA.bin $out/opt/spflashtool5/MTK_AllInOne_DA.bin
    install -Dm0644 $src/console_mode.xsd $out/opt/spflashtool5/console_mode.xsd
    install -Dm0644 $src/download_scene.ini $out/opt/spflashtool5/download_scene.ini
    install -Dm0644 $src/key.ini $out/opt/spflashtool5/key.ini
    install -Dm0644 $src/option.ini $out/opt/spflashtool5/option.ini
    install -Dm0644 $src/platform.xml $out/opt/spflashtool5/platform.xml
    install -Dm0644 $src/rb_without_scatter.xml $out/opt/spflashtool5/rb_without_scatter.xml
    install -Dm0644 $src/storage_setting.xml $out/opt/spflashtool5/storage_setting.xml
    install -Dm0644 $src/usb_setting.xml $out/opt/spflashtool5/usb_setting.xml

    install -Dm0755 $src/flash_tool $out/opt/spflashtool5/flash_tool
    install -Dm0755 $src/flash_tool.sh $out/opt/spflashtool5/flash_tool.sh

    echo "#!/usr/bin/env sh" > $out/bin/spflashtool5
    echo "$out/opt/spflashtool5/flash_tool.sh" >> $out/bin/spflashtool5
    chmod +x $out/bin/spflashtool5

    # Enable readback by scatter
    sed -i 's/ShowByScatter=false/ShowByScatter=true/' $out/opt/spflashtool5/option.ini
 
    # Disable welcome page at startup
    sed -i 's/ShowWelcome=true/ShowWelcome=false/' $out/opt/spflashtool5/option.ini

    runHook postInstall
  '';

  meta = {
    license = lib.licenses.unfree;
    homepage = "https://spflashtools.com/linux/sp-flash-tool-v5-2228-for-linux";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    description = "SP Flash Tool is an application to flash your MediaTek (MTK) SmartPhone.";
    platforms = [ "x86_64-linux" ];
    mainProgram = "spflashtool5";
  };
}
