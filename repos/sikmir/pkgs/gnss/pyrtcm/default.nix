{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyrtcm";
  version = "1.1.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyrtcm";
    tag = "v${version}";
    hash = "sha256-yQ/Mv3JOmHSM9IXO87nu93IikmhqI8/BAjS4E+XLLAc=";
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
