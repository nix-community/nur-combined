{
  lib,
  fetchFromGitHub,
  python3Packages,
  pygnssutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "pygpsclient";
  version = "1.5.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "PyGPSClient";
    tag = "v${version}";
    hash = "sha256-xtj1d/bT0Ks1NpSLH16oP7SUj1Uy0D9RHzknvbqXEQk=";
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
