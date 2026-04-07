# Disclaimer: Some Claude Opus 4.6 was used to write this
{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
  numpy,
  cython,
  scipy,
  fftw,
}:

buildPythonPackage rec {
  pname = "pyfftw";
  version = "0.15.1";
  pyproject = true;
  pythonRuntimeDepsCheck = false;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-u83m1A0WXhy68S3eBi6/6+nkM5TKyMFm5pm6LJpLBGE=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    cython
    scipy
  ];

  nativeBuildInputs = [
    fftw
  ];

  buildInputs = [
    fftw
  ];

  meta = with lib; {
    description = "A pythonic wrapper around FFTW";
    homepage = "https://github.com/pyFFTW/pyFFTW";
  };
}
