{
  channel,
  version,
  hash,
  gns3-server,
}:

{
  fetchFromGitHub,
  gns3-gui,
  lib,
  python3Packages,
  qt5,
  testers,
  wrapQtAppsHook,
}:

assert version != gns3-server.version -> throw "gns3-gui.version != gns3-server.version: ${version} != ${gns3-server.version}";

python3Packages.buildPythonApplication rec {
  pname = "gns3-gui";
  inherit version;

  src = fetchFromGitHub {
    inherit hash;
    owner = "GNS3";
    repo = "gns3-gui";
    rev = "refs/tags/v${version}";
  };

  nativeBuildInputs = with python3Packages; [ wrapQtAppsHook ];

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = [ qt5.qtwayland ];

  dependencies = with python3Packages; [
    distro
    jsonschema
    psutil
    sentry-sdk
    setuptools
    sip
    (pyqt5.override { withWebSockets = true; })
    truststore
  ] ++ lib.optionals (pythonOlder "3.9") [
    importlib-resources
  ];

  dontWrapQtApps = true;

  postPatch = ''
    # hardcode path to gns3server
    # fix: Error when connecting to the GNS3 server: Client version x is not the same as server version y
    # https://github.com/GNS3/gns3-gui/issues/2726
    substituteInPlace gns3/local_server.py \
      --replace-fail \
        'local_server_path = shutil.which(settings["path"].strip())' \
        'local_server_path = "${gns3-server}/bin/gns3server"' \

    # disable "check for update" by default
    # installing a new version from pypi would fail
    substituteInPlace gns3/settings.py \
      --replace-fail \
        '"check_for_update": True,' \
        '"check_for_update": False,' \
  '';

  preFixup = ''
    wrapQtApp "$out/bin/gns3"
  '';

  doCheck = true;

  checkInputs = with python3Packages; [ pytestCheckHook ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export QT_PLUGIN_PATH="${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${qt5.qtbase.bin}/lib/qt-${qt5.qtbase.version}/plugins";
    export QT_QPA_PLATFORM=offscreen
  '';

  passthru.tests.version = testers.testVersion {
    package = gns3-gui;
    command = "${lib.getExe gns3-gui} --version";
  };

  meta = {
    description = "Graphical Network Simulator 3 GUI (${channel} release)";
    longDescription = ''
      Graphical user interface for controlling the GNS3 network simulator. This
      requires access to a local or remote GNS3 server (it's recommended to
      download the official GNS3 VM).
    '';
    homepage = "https://www.gns3.com/";
    changelog = "https://github.com/GNS3/gns3-gui/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    mainProgram = "gns3";
  };
}
