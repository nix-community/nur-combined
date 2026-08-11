/*

nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'


toPythonModule (callPackage ../development/python-modules/pyside2 {
    inherit (pkgs) cmake ninja qt5;
  });

nixpkgs/pkgs/top-level/python-packages.nix

  pyside2-tools = toPythonModule (callPackage ../development/python-modules/pyside2-tools {
    inherit (pkgs) cmake qt5;
  });

  pyside2 = toPythonModule (callPackage ../development/python-modules/pyside2 {
    inherit (pkgs) cmake ninja qt5;
  });
*/
# todo publish https://github.com/NixOS/nixpkgs/issues/111501

{ buildPythonPackage, python, fetchurl, lib, stdenv,
  cmake, ninja, qt6, shiboken6 }:

let
  pnameCamel = "PySide6";
in

stdenv.mkDerivation rec {
  pname = "pyside6";
  version = "6.2.0";

  src = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/${pname}/${pnameCamel}-${version}-src/pyside-setup-opensource-src-${version}.tar.xz";
    sha256 = "/tIQtmISmVUzLSYJqQC1uGQxMBNORoI3GyapumB0DQE=";
  };

  srcShiboken = fetchurl {
    url = "https://download.qt.io/official_releases/QtForPython/${pname}/shiboken6-${version}-${version}-cp36.cp37.cp38.cp39.cp310-abi3-manylinux1_x86_64.whl";
    sha256 = "3OO0NNXRvlC4kgeZZHu7I0bf2TMb+SJCUSgIUCAJfLg=";
  };

  patches = [
    #./dont_ignore_optional_modules.patch
  ];

  postPatch = ''
    echo postPatch
    ls
    #ls sources
    #stat ${srcShiboken}

    ls
    find . -name setup.py

    #cd sources/${pname}
  '';

  configurePhase = ":";

  buildPhase = ''
    echo buildPhase
    python setup.py build
  '';

  installPhase = ''
    echo installPhase
    python setup.py install
  '';

  cmakeFlags = [
    "-DBUILD_TESTS=OFF"
    "-DPYTHON_EXECUTABLE=${python.interpreter}"
  ];

  nativeBuildInputs = [ cmake ninja qt6.qmake python ];
  buildInputs = with qt6; [
    qtbase qtxmlpatterns qtmultimedia qttools qtx11extras qtlocation qtscript
    qtwebsockets qtwebengine qtwebchannel qtcharts qtsensors qtsvg
  ];
  propagatedBuildInputs = [ shiboken6 ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "LGPL-licensed Python bindings for Qt";
    license = licenses.lgpl21;
    homepage = "https://wiki.qt.io/Qt_for_Python";
    maintainers = with maintainers; [ gebner ];
  };
}
