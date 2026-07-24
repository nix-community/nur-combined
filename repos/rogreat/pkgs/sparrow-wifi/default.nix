{
  copyDesktopItems,
  fetchFromGitHub,
  imagemagick,
  iw,
  lib,
  makeDesktopItem,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sparrow-wifi";
  version = "2.0";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ghostop14";
    repo = "sparrow-wifi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rmN7hGnt+zDAsRdJXC2KmJrhgmjxCPZgjpRlQ/HbPZA=";
  };

  dependencies = with python3Packages; [
    gps3
    matplotlib
    numpy
    pyqt5
    pyqtchart
    python-dateutil
    requests
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    qt5.wrapQtAppsHook
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/sparrow-wifi
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/sparrow-wifi.py \"\$@\"" >> $out/bin/sparrow-wifi
    chmod +x $out/bin/sparrow-wifi

    mkdir -p $out/${python3Packages.python.sitePackages}
    cp *.py $out/${python3Packages.python.sitePackages}

    mkdir -p $out/share/icons/hicolor/64x64/apps
    magick wifi_icon.png -resize 64x64 -gravity center -extent 64x64 \
        $out/share/icons/hicolor/64x64/apps/sparrow_wifi.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sparrow-wifi";
      desktopName = "Sparrow WiFi";
      icon = "sparrow_wifi";
      exec = "sparrow-wifi";
      comment = "WiFi and Bluetooth Analyzer";
      categories = [ "Utility" ];
    })
  ];

  preFixup = ''
    qtWrapperArgs+=(
        --set PYTHONPATH "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
        --set PATH "${
          lib.makeBinPath [
            iw
          ]
        }"
    )
    wrapProgram $out/bin/sparrow-wifi ''${qtWrapperArgs[@]}
  '';

  meta = {
    description = "Next-Gen GUI-based WiFi and Bluetooth Analyzer for Linux";
    homepage = "https://github.com/ghostop14/sparrow-wifi";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "sparrow-wifi";
    platforms = lib.platforms.linux;
  };
})
