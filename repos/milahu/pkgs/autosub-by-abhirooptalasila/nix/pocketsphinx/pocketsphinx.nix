{ lib
, buildPythonPackage
, fetchPypi
, pkgs
, python
}:

buildPythonPackage rec {
  # binary release only for windows + mac
  pname = "pocketsphinx";
  version = "0.1.15";
  src = fetchPypi {
    inherit pname version;
    sha256 = "NNKQdFx9vm+iysmBW1wZ0Q85PlKOzXDnecIevESPm2M=";
  };
  nativeBuildInputs = [
    pkgs.swig
    python
  ];
  propagatedBuildInputs = ([
    #zipp
  ]);
  buildInputs = ([
    pkgs.pulseaudio
    pkgs.alsaLib
    pkgs.pocketsphinx
    pkgs.sphinxbase # yes we need both, pocketsphinx and sphinxbase
  ]);
  meta = with lib; {
    homepage = "https://github.com/bambocher/pocketsphinx-python";
    description = "Python interface to CMU Sphinxbase and Pocketsphinx libraries";
    license = licenses.bsdOriginal;
  };
  doCheck = false;
  /*
  FIXME
    tests (unittest.loader._FailedTest) ... ERROR
    ======================================================================
    ERROR: tests (unittest.loader._FailedTest)
    ----------------------------------------------------------------------
    ImportError: Failed to import test module: tests
    Traceback (most recent call last):
    File "/nix/store/fkzla307l4mlcvfyshsrccwl7szihx2z-python3-3.9.6/lib/python3.9/unittest/loader.py", line 154, in loadTestsFromName
        module = __import__(module_name)
    ModuleNotFoundError: No module named 'tests'

    */
}
