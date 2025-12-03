{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  numba,
  opencv-python,
}:

buildPythonPackage rec {
  pname = "largestinteriorrectangle";
  version = "0.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OpenStitching";
    repo = "lir";
    rev = "v${version}";
    hash = "sha256-NnifUCe7bW1g477bGO3SGKO1DwOkVkA1Khwhg83afNk=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numba
    opencv-python
  ];

  pythonImportsCheck = [
    "largestinteriorrectangle"
  ];

  meta = {
    description = "Largest Interior/Inscribed Rectangle implementation in Python";
    homepage = "https://github.com/OpenStitching/lir";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
