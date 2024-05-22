{
  lib,
  fetchFromGitHub,
  python3Packages,
  pygnssutils,
}:

python3Packages.buildPythonApplication rec {
  pname = "pygpsclient";
  version = "1.4.12";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "PyGPSClient";
    rev = "v${version}";
    hash = "sha256-/TOEI0l/FJx8yENxFhruKp+I4N+vDS80oGdTSrNdsDU=";
  };

  build-system = with python3Packages; [ setuptools ];

  propagatedBuildInputs = with python3Packages; [
    requests
    pillow
    pygnssutils
    pyserial
    tkinter
  ];

  meta = with lib; {
    description = "GNSS Diagnostic and UBX Configuration GUI Application";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
