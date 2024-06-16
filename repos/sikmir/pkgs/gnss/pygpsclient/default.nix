{
  lib,
  fetchFromGitHub,
  python3Packages,
  pygnssutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "pygpsclient";
  version = "1.4.17";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "PyGPSClient";
    rev = "v${version}";
    hash = "sha256-kDdicLzjqfFAMU2SxMToBXmIqfRvQ3r/2ACi/cvVIcU=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    pillow
    pygnssutils
    pyserial
    tkinter
  ];

  meta = {
    description = "GNSS Diagnostic and UBX Configuration GUI Application";
    homepage = "https://github.com/semuconsulting/PyGPSClient";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
