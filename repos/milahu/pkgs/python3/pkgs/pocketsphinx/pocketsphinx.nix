{ lib
, stdenv
, buildPythonPackage
, fetchPypi
, pkgs
, python
, scikit-build
#, python-extensions
, cython
, sounddevice
}:

buildPythonPackage rec {
  pname = "pocketsphinx";
  version = pkgs.pocketsphinx.version;

  src = pkgs.pocketsphinx.src;

  /*
  src = fetchPypi {
    inherit pname version;
    hash = "";
  };
  */

  # fix: checkPhase would re-run configure + build + install
  # and would try to install to wrong prefix: ${python3} instead of $out
  setuptoolsCheckPhase = ":";

  nativeBuildInputs = [
    #pkgs.swig
    pkgs.cmake
    #python
    cython
    #scikit-build # skbuild
  ];

  propagatedBuildInputs = ([
    sounddevice
  ]);

  # dont run cmake in configurePhase
  # cmake is called from the python build system
  dontConfigure = true;

  buildInputs = ([
/*
    pkgs.pulseaudio
    pkgs.alsaLib
    #pkgs.pocketsphinx
    #python-extensions
*/
    scikit-build # skbuild
  ]);

  meta = with lib; {
    homepage = "https://github.com/bambocher/pocketsphinx-python";
    description = "Python interface to CMU Pocketsphinx library";
    license = licenses.mit;
  };
}
