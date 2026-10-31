{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pysbf2";
  version = "1.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pysbf2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XVbrjBOoKpRdKA0+Cmf5u/GHKgEa+jgRTHshLbLxDHg=";
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
})
