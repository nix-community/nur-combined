{
  pkgs,
  lib,
  buildPythonPackage,
  fetchPypi,
  cython,
  numpy,
  setuptools,
  wheel,
  build,
}:

let
  # until https://github.com/NixOS/nixpkgs/pull/370195 is not merged
  ta-lib = pkgs.ta-lib.overrideAttrs rec {
    version = "0.6.2";
    src = pkgs.fetchFromGitHub {
      owner = "TA-Lib";
      repo = "ta-lib";
      rev = "v${version}";
      sha256 = "sha256-asTNJIdIq2pxQ0Lz+rbyDVBpghlsQqqvPy1HFi8BbN0=";
    };
  };
in
buildPythonPackage rec {
  pname = "ta-lib";
  version = "0.6.8";
  pyproject = true;

  src = fetchPypi {
    pname = "ta_lib";
    inherit version;
    hash = "sha256-OpGVKZ3519Km6dFr69a3BrDqmeS4cYZMSwNMJXfiGnc=";
  };

  buildInputs = [ ta-lib ];

  build-system = [
    cython
    numpy
    setuptools
    wheel
  ];

  dependencies = [
    build
    numpy
  ];

  pythonImportsCheck = [
    "talib"
  ];

  meta = {
    description = "Python wrapper for TA-Lib";
    homepage = "https://pypi.org/project/TA-Lib";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
