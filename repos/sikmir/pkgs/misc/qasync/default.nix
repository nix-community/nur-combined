{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "qasync";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "CabbageDevelopment";
    repo = "qasync";
    rev = "v${version}";
    hash = "sha256-VM4+HNqqiVfGS6FzOjf2LAfcIFA3VuNAhpwkxzOlLOE=";
  };

  doCheck = false;

  meta = {
    description = "Python library for using asyncio in Qt-based applications";
    inherit (src.meta) homepage;
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
