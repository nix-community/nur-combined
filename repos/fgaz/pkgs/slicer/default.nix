{ stdenv, fetchFromGitHub
, cmake, subversion, git, qmake, bison
, qtbase, qtquickcontrols2, qtscript, qtwebengine, qtx11extras
, python3
, python2
, curl
, tcl
, tk
, xorg
, perl }:


stdenv.mkDerivation rec {
  name = "slicer-${version}";
  version = "4.8.1";
  src = fetchFromGitHub {
    owner = "Slicer";
    repo = "Slicer";
    rev = "v${version}";
    sha256 = "0732g8qf6svwxiwhx60yfy5ww0vv00j4ja66h3fr9h6lwwnlfwrv";
  };
  nativeBuildInputs = [ cmake qmake subversion git bison curl perl ];
  buildInputs = [
    qtbase
    qtscript
    qtwebengine
    qtx11extras
    tcl
    tk
    xorg.libXt
    (python2.withPackages (pp: with pp; [
      pyparsing
      packaging
      chardet
      gitdb2
      PyGithub
      appdirs
      six
      smmap2
      nose
      GitPython
      wheel
      pip
      numpy
    ]))
    (import ./python/requirements.nix { }).packages.dicom
    (import ./python/requirements.nix { }).packages.pydicom
    (import ./python/requirements.nix { }).packages.CouchDB
  ];
  configurePhase = ''
    #rm CMake/SlicerCheckCMakeHTTPS.cmake
    #sed -i '/SlicerCheckCMakeHTTPS/d' SuperBuild.cmake
    mkdir build
    #mkdir -p build/source/build/tcl-prefix/src
    #curl http://slicer.kitware.com/midas3/download/item/155630/tcl8.6.1-src.tar.gz > build/source/build/tcl-prefix/src/tcl8.6.1-src.tar.gz
    cd build
    cmake .. -DCMAKE_INSTALL_PREFIX=$out -DCMAKE_BUILD_TYPE:STRING=Release -DQt5_DIR:PATH=${qtbase}/lib/cmake/Qt5 -DSlicer_USE_SYSTEM_python=true
  '';
  meta.broken=true;
}

