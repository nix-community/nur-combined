{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyrtcm";
  version = "1.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    rev = "v${version}";
    hash = "sha256-YD/ewNEv0iPwKk606Q1Mg4qFAUb9Jse5z5S1QZvq/kY=";
  };

  build-system = with python3Packages; [ setuptools ];

  pythonImportsCheck = [ "pyrtcm" ];

  meta = {
    description = "RTCM3 protocol parser";
    homepage = "https://github.com/semuconsulting/pyrtcm";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
