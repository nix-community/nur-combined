{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "pyqgc";
  version = "1.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyqgc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zKEani5P3FxdEW5LIgCpTnsVb38S5hWAaXtQ0gTXh5g=";
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
