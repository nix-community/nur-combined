{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage rec {
  pname = "smopy";
  version = "0.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rossant";
    repo = "smopy";
    tag = "v${version}";
    hash = "sha256-ds3BQryv9uwJYfpqbFOT7Cxm2HkHhfVqvu8eeyaAET0=";
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
}
