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
  pname = "pbmsc";
  version = "3.5.5.16";

  src = fetchurl {
    url = "https://github.com/psyk2642/iBMSC/releases/download/pBMSC-3.5.5.16/pBMSC.3.5.5.16.zip";
    sha256 = "1b1y123kqr60x7xs6g8bc1c3xp1hsdjdji8hxfac7qjm8rn0andf";
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

     install -Dm755 ${./pbmsc.sh} $out/bin/pbmsc
     substituteInPlace $out/bin/pbmsc \
       --replace-fail "@out@" "$out" \
       --replace-fail "@wineWow64Packages@" "${wineWow64Packages.full}"

      copyDesktopItems
  '';

  # Desktop item will be connected by consumer overlay; define here
  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "pBMSC";
      exec = pname;
      comment = "iBMSC/pBMSC chart editor (runs via Wine)";
      categories = [
        "AudioVideo"
        "Audio"
      ];
      terminal = false;
      keywords = [
        "BMS"
        "Chart"
        "Editor"
      ];
      startupWMClass = "pBMSC";
      icon = "wine";
    })
  ];

  propagatedBuildInputs = [ wineWow64Packages.full ];

  meta = with lib; {
    description = "pBMSC (iBMSC Windows build) packaged to run with Wine";
    homepage = "https://github.com/psyk2642/iBMSC";
    license = licenses.unfreeRedistributable;
    maintainers = [ ];
    platforms = wineWow64Packages.full.meta.platforms;
    mainProgram = pname;
  };
}
