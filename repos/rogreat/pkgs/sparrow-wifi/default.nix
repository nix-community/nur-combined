{
  fetchFromGitHub,
  gobject-introspection,
  iw,
  lib,
  python3Packages,
  qt5,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sparrow-wifi";
  version = "0-unstable-2026-02-24";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ghostop14";
    repo = "sparrow-wifi";
    rev = "ab1fe0e517dec20f147a2bccc42e122fcdb5ba00";
    hash = "sha256-Q5mGLi4cTF+7GqddueDIAhlROzGVCQjSlyUn/0nnLK0=";
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
    qt5.wrapQtAppsHook
  ];

  installPhase = ''
    runHook preInstall
    install -Dm555 sparrow-wifi.py $out/bin/sparrow-wifi
    modules=(
      "sparrowbluetooth"
      "sparrowcommon"
      "sparrowdialogs"
      "sparrowgps"
      "sparrowhackrf"
      "sparrowmap"
      "sparrowrpi"
      "sparrowtablewidgets"
      "sparrowwifiagent"
      "telemetry"
      "wirelessengine"
    )
    for module in "''${modules[@]}"; do
      install -Dm444 $module.py $out/${python3Packages.python.sitePackages}/$module.py
    done
    runHook postInstall
  '';

  dontWrapQtApps = true;

  preFixup = ''
    makeWrapperArgs+=(
      "''${qtWrapperArgs[@]}"
      --suffix PATH : "${
        lib.makeBinPath [
          iw
        ]
      }"
    )
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
