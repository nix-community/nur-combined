{
  lib,
  fetchFromGitHub,
  python3Packages,
  pygnssutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "pygpsclient";
  version = "1.4.21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "PyGPSClient";
    rev = "v${version}";
    hash = "sha256-0Li+X0cJvfuFg0UMEPiSCiqO4n83MfMnDh0TCSvWvo4=";
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
