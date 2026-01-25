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
  pname = "mbmplay";
  version = "3.24.0824.1";

  src = fetchurl {
    url = "https://mistyblue.info/php/dl.php?file=mbmplay_3240824_1_x64.zip";
    sha256 = "0xingp3xpkb0wdsn2iwphskgg179vi45a8cr7yl3dznp3vxklxmz";
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

    install -Dm755 ${./mbmplay.sh} $out/bin/mbmplay
    substituteInPlace $out/bin/mbmplay \
      --replace-fail "@out@" "$out" \
      --replace-fail "@wineWow64Packages@" "${wineWow64Packages.full}"

    # 安装桌面文件
    copyDesktopItems
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "mBMplay";
      exec = pname;
      comment = "mBMplay - BMS previewer (runs via Wine)";
      categories = [
        "Game"
        "AudioVideo"
        "Audio"
      ];
      terminal = false;
      keywords = [
        "BMS"
        "mBMplay"
        "Player"
      ];
      startupWMClass = "mBMplay";
      icon = "wine";
    })
  ];

  propagatedBuildInputs = [ wineWow64Packages.full ];

  meta = with lib; {
    description = "mBMplay - BMS previewer (runs via Wine)";
    homepage = "https://mistyblue.info";
    license = licenses.mit;
    maintainers = [ ];
    platforms = wineWow64Packages.full.meta.platforms;
    mainProgram = pname;
  };
}
