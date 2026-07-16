{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyqgc,
  pysbf2,
  pyspartn,
  pyubx2,
  pyubxutils,
  pyunigps,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pygnssutils";
  version = "1.2.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1mnieWIYzMNFUDYxvax3Tzl6/oaupT3lafTy4ZAo/X4=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    certifi
    paho-mqtt
    pyqgc
    pysbf2
    pyserial
    pyspartn
    pyubx2
    pyubxutils
    pyunigps
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = {
    description = "GNSS Command Line Utilities";
    homepage = "https://github.com/semuconsulting/pygnssutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
