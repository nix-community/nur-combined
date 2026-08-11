{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  python3,

  buildPythonPackage,

  scikit-build-core,
  nanobind,
  setuptools,
  wheel,
  cibuildwheel,

  numpy,
}:

buildPythonPackage rec {
  pname = "doxapy";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "brandonmpetty";
    repo = "Doxa";
    tag = "v${version}-doxapy";
    hash = "sha256-aodsAWOOnuamJqu9dIQO2dW98q76oMlMh0GPvT1VROA=";
  };

  sourceRoot = "source/Bindings/Python";

  pyproject = true;

  # fix: error: Doxa/BinarizationFactory.hpp: No such file or directory
  # TODO better? use headers from a separate "doxa" package?
  preBuild = ''
    cp -r ../../Doxa src
  '';

  nativeBuildInputs = [
    cmake
    ninja
  ];

  # cmake is called from python
  dontUseCmakeConfigure = true;
  dontUseCmakeBuild = true;

  build-system = [
    scikit-build-core
    nanobind
    setuptools
    wheel
    cibuildwheel
  ];

  dependencies = [
    numpy
  ];

  pythonImportsCheck = [ "doxapy" ];

  meta = {
    description = "A Local Adaptive Thresholding framework for image binarization";
    homepage = "https://github.com/brandonmpetty/Doxa";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
