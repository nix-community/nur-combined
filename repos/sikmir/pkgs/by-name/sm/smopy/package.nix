{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "smopy";
  version = "0.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rossant";
    repo = "smopy";
    rev = "e21196ad8ded7338c30448392f8f72437c82b965";
    hash = "sha256-6XCsTCvk37UV6dFT4OcB/DJhHapV/o0kMmZ4XOoYq9I=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    numpy
    ipython
    pillow
    matplotlib
  ];

  pythonImportsCheck = [ "smopy" ];

  meta = {
    description = "OpenStreetMap image tiles in Python";
    homepage = "https://github.com/rossant/smopy";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
