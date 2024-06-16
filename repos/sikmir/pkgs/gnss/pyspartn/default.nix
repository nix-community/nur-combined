{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyspartn";
  version = "1.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyspartn";
    rev = "v${version}";
    hash = "sha256-YfsC9mErwsIiy1udmR7GFRJBzVLHkQL3Uy2RTBGIyxs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ cryptography ];

  pythonImportsCheck = [ "pyspartn" ];

  meta = {
    description = "SPARTN protocol parser";
    homepage = "https://github.com/semuconsulting/pyspartn";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
