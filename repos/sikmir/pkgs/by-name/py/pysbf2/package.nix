{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage rec {
  pname = "pysbf2";
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pysbf2";
    tag = "v${version}";
    hash = "sha256-0GBk7MytxkwCM9WNWk+bJo4JlwUgC5Xwex+zZNR6Hqo=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pynmeagps
    pyrtcm
  ];

  pythonImportsCheck = [ "pysbf2" ];

  meta = {
    description = "SBF protocol parser and generator";
    homepage = "https://github.com/semuconsulting/pysbf2";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
