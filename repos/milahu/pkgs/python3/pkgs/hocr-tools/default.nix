{ lib
, buildPythonApplication
, fetchFromGitHub
, setuptools
, wheel
, lxml
, pillow
, reportlab
, python-bidi
}:

buildPythonApplication rec {
  pname = "hocr-tools";
  version = "unstable-2024-03-16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tmbdev";
    repo = pname;
    #rev = "v${version}";
    rev = "c093088da0863cfe5242c0d79a4ac067c991c192";
    hash = "sha256-457KqA+PqBUgx3aKo83xuAptutPymUOIptby3d6Pdso=";
  };

  # hocr-tools uses a test framework that requires internet access
  doCheck = false;

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    pillow
    lxml
    reportlab
    (python-bidi.override { version = "0.4.0"; })
  ];

  meta = with lib; {
    description = "Tools for manipulating and evaluating the hOCR format for representing multi-lingual OCR results by embedding them into HTML";
    homepage = "https://github.com/tmbdev/hocr-tools";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
