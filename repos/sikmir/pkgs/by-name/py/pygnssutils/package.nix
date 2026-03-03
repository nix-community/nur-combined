{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyqgc,
  pysbf2,
  pyspartn,
  pyubx2,
  pyubxutils,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pygnssutils";
  version = "1.1.22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pygnssutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OiNXm+AT+1zNpRhZ4FkBrsrtjURzKhyoVYORTciMg0w=";
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
  ];

  pythonImportsCheck = [ "pygnssutils" ];

  meta = {
    description = "GNSS Command Line Utilities";
    homepage = "https://github.com/semuconsulting/pygnssutils";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
