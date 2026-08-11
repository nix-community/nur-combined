{
  lib,
  buildPythonPackage,
  setuptools,
  wheel,
  pkgs-qtermwidget,
  sip,
  pyqt-builder,
  qt6,
  pyqt6,
  pyqt6-sip,
  python,
  libGL,
}:

buildPythonPackage rec {
  pname = "qtermwidget";
  pyproject = true;

  inherit (pkgs-qtermwidget) version src meta;

  sourceRoot = "source/pyqt";

  postPatch = ''
    cat >>pyproject.toml <<'EOF'
    [tool.sip.project]
    # fix: qtermwidget.sip: 'QtCore/QtCoremod.sip' could not be found
    sip-include-dirs = [ "${pyqt6}/${python.sitePackages}/PyQt6/bindings" ]
    # fix: _in_process.py: 'make' failed returning 2
    # debug run_command in sipbuild/project.py
    # https://stackoverflow.com/a/79740420/10440128
    verbose = true
    [tool.sip.bindings.QTermWidget]
    # fix: error: qtermwidget.h: No such file or directory
    include-dirs = [
        "${pkgs-qtermwidget}/include/qtermwidget6",
    ]
    # fix: ld: cannot find -lQt6Gui: No such file or directory
    library-dirs = [
        "${qt6.qtbase}/lib", # libQt6Gui.so libQt6Core.so
        "${libGL}/lib", # libGLX.so libOpenGL.so
    ]
    EOF
  '';

  build-system = [
    setuptools
    wheel
    sip # sipbuild
    pyqt-builder
    qt6.qtbase # qmake
  ];

  dependencies = [
    pyqt6
    pyqt6-sip
  ];

  buildInputs = [
    pkgs-qtermwidget # qtermwidget.h libqtermwidget.so
  ];

  dontWrapQtApps = true;

  pythonImportsCheck = [
    "QTermWidget"
  ];
}
