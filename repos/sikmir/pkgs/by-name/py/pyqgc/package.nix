{
  lib,
  fetchFromGitHub,
  python3Packages,
  pyrtcm,
}:

python3Packages.buildPythonPackage rec {
  pname = "pyqgc";
  version = "0.1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "pyqgc";
    tag = "v${version}";
    hash = "sha256-n8D5dYbpygaVr397MdT6qeAl2bL61rvw0kpZ/Z5PohU=";
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
}
