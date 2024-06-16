{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonPackage {
  pname = "thinplatespline";
  version = "0-unstable-2024-02-06";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "thinplatespline";
    rev = "81f40c74663d9510ceedf57a04a711ec7fc8b7fa";
    hash = "sha256-1U5WEPFH5dhf2lkfZY6rrwlUNq/rY2mSlgEZVnReyng=";
  };

  doCheck = false;

  pythonImportsCheck = [ "tps" ];

  meta = {
    description = "Python library for thin plate spline calculations";
    homepage = "https://github.com/wladich/thinplatespline";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
