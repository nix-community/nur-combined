{
  lib,
  stdenvNoCC,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  p7zip,
  wineWow64Packages,
}:

stdenvNoCC.mkDerivation rec {
  pname = "mbmconfig";
  version = "3.24.0824.0";

  src = fetchurl {
    url = "https://mistyblue.info/php/dl.php?file=mbmconfig_3240824_0_x64.zip";
    sha256 = "707b8f82433234d586114080a8f00ff9920f0bb885574b17f38e5ba05f4235a3";
  };

  dontUnpack = true;
  dontBuild = true;
  nativeBuildInputs = [
    copyDesktopItems
    p7zip
  ];

  installPhase = ''
    install -dm755 $out/share/${pname}
    7z x -y -o"$out/share/${pname}" "$src"
    # 修正反斜杠为目录分隔符
    while IFS= read -r -d $'\0' p; do
      case "$p" in
        *\\*)
          target="''${p//\\//}"
          if [ "$p" != "$target" ]; then
            mkdir -p "$(dirname "$target")"
            mv -f "$p" "$target"
          fi
        ;;
      esac
    done < <(find "$out/share/${pname}" -depth -print0)

    chmod -R u+rwX,go+rX $out/share/${pname}

    install -Dm755 ${./mbmconfig.sh} $out/bin/mbmconfig
    substituteInPlace $out/bin/mbmconfig \
      --replace "@out@" "$out" \
      --replace "@wineWow64Packages@" "${wineWow64Packages.full}"

    # 安装桌面文件
    copyDesktopItems
  '';

  # Desktop item will be connected by consumer overlay; define here
  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "mBMconfig";
      exec = pname;
      comment = "mBMplay GUI configuration tool (runs via Wine)";
      categories = [
        "AudioVideo"
        "Audio"
        "Settings"
      ];
      terminal = false;
      keywords = [
        "BMS"
        "mBMplay"
        "Configuration"
        "Settings"
      ];
      startupWMClass = "mBMconfig";
      icon = "wine";
    })
  ];

  propagatedBuildInputs = [ wineWow64Packages.full ];

  meta = with lib; {
    description = "mBMconfig - GUI configuration tool for mBMplay (runs via Wine)";
    homepage = "https://mistyblue.info";
    license = licenses.mit;
    maintainers = [ ];
    platforms = wineWow64Packages.full.meta.platforms;
    mainProgram = pname;
  };
}
