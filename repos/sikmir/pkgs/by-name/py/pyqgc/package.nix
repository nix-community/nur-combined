{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyqgc";
  version = "0.2.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyqgc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k41Sh8txGMmUDnwzH/xQRe/pT1LXG8mN3frZYY9guNk=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pynmeagps
    pyrtcm
  ];

  pythonImportsCheck = [ "pyqgc" ];

  meta = {
    description = "Python library for parsing and generating Quectel QGC GPS/GNSS protocol messages";
    homepage = "https://github.com/semuconsulting/pyqgc";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
