{
  lib,
  fetchFromGitHub,
  python3Packages,
  pygnssutils,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pygpsclient";
  version = "1.7.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "semuconsulting";
    repo = "PyGPSClient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iNbZqirZ7miQsG42fjZC0PLvd+4QWk0BBktU/Wn4tak=";
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
})
