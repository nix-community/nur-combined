{
  copyDesktopItems,
  fetchFromGitHub,
  imagemagick,
  iw,
  lib,
  makeDesktopItem,
  python3Packages,
  qt5,
  usbutils,
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

  # https://github.com/ghostop14/sparrow-wifi/blob/master/requirements.txt
  dependencies = with python3Packages; [
    # qscintilla
    pyqtchart
    gps3
    # dronekit
    # manuf
    python-dateutil
    numpy
    matplotlib
    requests
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    qt5.wrapQtAppsHook
  ];

  installPhase = ''
    runHook preInstall

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
      categories = [
        "Network"
        "Utility"
      ];
    })
  ];

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapper ${python3Packages.python.interpreter} $out/bin/sparrow-wifi \
        --add-flags "-m sparrow-wifi" \
        ''${qtWrapperArgs[@]} \
        --set PYTHONPATH $out/${python3Packages.python.sitePackages}:$PYTHONPATH \
        --set PATH ${
          lib.makeBinPath [
            iw
            usbutils
          ]
        }
  '';

  nativeCheckInputs = [ python3Packages.pytestCheckHook ];

  enabledTestPaths = [ "tests/" ];

  strictDeps = true;

  __structuredAttrs = true;

  meta = {
    description = "Next-Gen GUI-based WiFi and Bluetooth Analyzer for Linux";
    homepage = "https://github.com/ghostop14/sparrow-wifi";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "sparrow-wifi";
    platforms = lib.platforms.linux;
  };
})
