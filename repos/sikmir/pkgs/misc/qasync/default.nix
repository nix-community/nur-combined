{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "qasync";
  version = "0.22.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "CabbageDevelopment";
    repo = "qasync";
    tag = "v${version}";
    hash = "sha256-VM4+HNqqiVfGS6FzOjf2LAfcIFA3VuNAhpwkxzOlLOE=";
  };

  build-system = with python3Packages; [ setuptools ];

  doCheck = false;

  meta = {
    description = "Python library for using asyncio in Qt-based applications";
    homepage = "https://github.com/CabbageDevelopment/qasync";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
