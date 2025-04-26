{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyspartn,
  pyubx2,
  pyubxutils,
}:

python3Packages.buildPythonPackage rec {
  pname = "pygnssutils";
  version = "1.1.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    tag = "v${version}";
    hash = "sha256-mVdMHyHEyG/QOuErvehnBSyUQmlKap8lIEqicP2N9Lw=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    certifi
    paho-mqtt
    pyserial
    pyspartn
    pyubx2
    pyubxutils
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = {
    description = "GNSS Command Line Utilities";
    homepage = "https://github.com/semuconsulting/pygnssutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
