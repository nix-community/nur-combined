{
  lib,
  stdenvNoCC,
  fetchzip,
  copyDesktopItems,
  imagemagick,
  xdg-utils,
  makeDesktopItem,
  makeWrapper,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ariang";
  version = "1.3.14";
  src = fetchzip {
    url = "https://github.com/mayswind/AriaNg/releases/download/${version}/AriaNg-${version}.zip";
    hash = "sha256-pBZCHAHXJBHZk765qrxcI3UtUg9NkzzmaBOFwD+mrjk=";
    stripRoot = false;
  };
  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    imagemagick
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname}
    cp -r * $out/share/${pname}

    for size in 16 24 36 48 72; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      magick $out/share/${pname}/tileicon.png -resize ''${size}x''${size} \
        $out/share/icons/hicolor/''${size}x''${size}/apps/${pname}.png
    done

    mkdir -p $out/bin
    makeWrapper ${xdg-utils}/bin/xdg-open $out/bin/${pname} \
      --add-flags "file://$out/share/${pname}/index.html"

    runHook postInstall
  '';
  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "AriaNg";
      genericName = meta.description;
      comment = meta.description;
      exec = pname;
      icon = pname;
      terminal = false;
      type = "Application";
      categories = [
        "Network"
        "WebBrowser"
      ];
    })
  ];

  meta = {
    description = "Modern web frontend making aria2 easier to use (built from bin files)";
    homepage = "http://ariang.mayswind.net/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
