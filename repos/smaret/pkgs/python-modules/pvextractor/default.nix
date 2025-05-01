{
  lib,
  fetchPypi,
  fetchpatch2,
  buildPythonPackage,
  astropy,
  matplotlib,
  scipy,
  qtpy,
  spectral-cube,
  pytestCheckHook,
  pytest-astropy,
  setuptools,
  setuptools_scm,
}:

buildPythonPackage rec {
  pname = "pvextractor";
  version = "0.4";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-7WoRWTXoPm+qdycQfpYbxJ15FP7IXjMm5a32XN4eg84=";
  };

  patches = [
    (fetchpatch2 {
      # Fix distutils deprecation on Python >= 3.12
      # See https://github.com/radio-astro-tools/pvextractor/issues/129
      url = "https://github.com/radio-astro-tools/pvextractor/pull/129/commits/2191f5fd557cea80448a0beeb7e3fd0a12ab8ed2.patch";
      hash = "sha256-V4rxNnN3YQPjUo8TWhTS6xMqajOJwd0o/1VOocypU1A=";
    })
  ];

  build-system = [
    setuptools
    setuptools_scm
  ];

  dependencies = [
    astropy
    matplotlib
    scipy
    qtpy
    spectral-cube
  ];

  checkInputs = [
    pytestCheckHook
    pytest-astropy
  ];

  disabledTests = [
    # segfaults with Matplotlib 3.1 and later
    "gui"
  ];

  meta = {
    changelog = "https://github.com/radio-astro-tools/pvextractor/releases/tag/${version}";
    description = "Position-Velocity Diagram Extractor";
    homepage = "https://pvextractor.readthedocs.io";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ smaret ];
  };
}
