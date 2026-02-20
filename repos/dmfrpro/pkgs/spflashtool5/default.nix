{ pkgs, ... }:

let
  wrapper = pkgs.writeShellScriptBin "spflashtool5" ''
    dir='@optDir@'
    if [ -n "''${LD_LIBRARY_PATH:-}" ]; then
      export LD_LIBRARY_PATH="''${LD_LIBRARY_PATH}:''${dir}:''${dir}/lib"
    else
      export LD_LIBRARY_PATH="''${dir}:''${dir}/lib"
    fi

    # Segfault fixes
    export FONTCONFIG_PATH='@fontconfigDir@'
    export LC_ALL=C

    exec "''${dir}/flash_tool" "''$@"
  '';

  fontconfigConf = pkgs.writeText "fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <include>${pkgs.fontconfig.out}/etc/fonts/fonts.conf</include>
      <dir>@fontDir@</dir>
      <rejectfont>
        <pattern>
          <patelt name="family">
            <string>Noto Color Emoji</string>
          </patelt>
        </pattern>
      </rejectfont>
      <rejectfont>
        <pattern>
          <patelt name="family">
            <string>EmojiOne Color</string>
          </patelt>
        </pattern>
      </rejectfont>
      <rejectfont>
        <pattern>
          <patelt name="family">
            <string>Twitter Color Emoji</string>
          </patelt>
        </pattern>
      </rejectfont>
    </fontconfig>
  '';
in

pkgs.stdenv.mkDerivation rec {
  pname = "spflashtool5";
  version = "5.2228";

  src = pkgs.fetchzip {
    url = "https://spflashtools.com/wp-content/uploads/SP_Flash_Tool_v${version}_Linux.zip";
    sha256 = "sha256-QZYltrfb7Sp+rmNfqgffKfbvBKlF8q0KhUnUyxaafFI=";
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "SP FlashTool 5";
    exec = "spflashtool5";
    icon = ../../share/icons/spflashtool5.png;
    comment = meta.description;
    desktopName = "SP FlashTool 5";
    genericName = "Mediatek FlashTool V5";
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
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = with pkgs; [
    bash
    stdenv.cc.cc.lib
    fontconfig
    freetype
    glib
    libxrender
    libxext
    libx11
    libsm
    libice
    zlib
    liberation_ttf
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/spflashtool5/{lib,fonts,fontconfig} $out/bin

    cp -r $src/lib/pkgconfig $out/opt/spflashtool5/lib/

    install -Dm0644 $src/lib/lib* \
                    $src/libflashtool{,.v1}.so \
                    $src/libflashtoolEx.so \
                    $src/libsla_challenge.so \
                    -t $out/opt/spflashtool5/lib/

    install -Dm0644 $src/MTK_AllInOne_DA.bin \
                    $src/console_mode.xsd \
                    $src/download_scene.ini \
                    $src/key.ini \
                    $src/option.ini \
                    $src/platform.xml \
                    $src/rb_without_scatter.xml \
                    $src/storage_setting.xml \
                    $src/usb_setting.xml \
                    -t $out/opt/spflashtool5/

    install -Dm0755 $src/flash_tool $out/opt/spflashtool5/flash_tool

    substituteInPlace $out/opt/spflashtool5/option.ini \
      --replace-fail "ShowByScatter=false" "ShowByScatter=true" \
      --replace-fail "ShowWelcome=true" "ShowWelcome=false"

    mkdir -p $out/opt/spflashtool5/fonts
    cp ${pkgs.liberation_ttf}/share/fonts/truetype/*.ttf \
      $out/opt/spflashtool5/fonts/

    cp ${fontconfigConf} $out/opt/spflashtool5/fontconfig/fonts.conf
    substituteInPlace $out/opt/spflashtool5/fontconfig/fonts.conf \
      --replace '@fontDir@' "$out/opt/spflashtool5/fonts"

    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/bin
    cp ${wrapper}/bin/spflashtool5 $out/bin/spflashtool5
    substituteInPlace $out/bin/spflashtool5 \
      --replace '@optDir@' "$out/opt/spflashtool5" \
      --replace '@fontconfigDir@' "$out/opt/spflashtool5/fontconfig"
  '';

  meta = {
    license = pkgs.lib.licenses.unfree;
    homepage = "https://spflashtools.com/linux/sp-flash-tool-v5-${version}-for-linux";
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
    maintainers = [ "dmfrpro" ];
    description = "SP Flash Tool is an application to flash your MediaTek (MTK) SmartPhone";
    platforms = [ "x86_64-linux" ];
    mainProgram = "spflashtool5";
  };
}
