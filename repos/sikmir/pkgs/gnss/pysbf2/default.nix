{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage rec {
  pname = "pysbf2";
  version = "1.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pysbf2";
    tag = "v${version}";
    hash = "sha256-3Iez0VwHgNh17zcPUQtpqN7klr9HT6p3dEMQGrn7sCk=";
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
