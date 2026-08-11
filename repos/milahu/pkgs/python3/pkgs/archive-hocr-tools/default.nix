{ lib
, python3
, fetchFromGitHub
, buildPythonApplication
, setuptools
, wheel
, ebooklib
, pillow
, python-fontconfig
, tqdm
, psutil
, numpy
, doxapy
}:

buildPythonApplication rec {
  pname = "archive-hocr-tools";
  version = "1.1.67-e2d3dc1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "internetarchive";
    repo = "archive-hocr-tools";
    # rev = version;
    # https://github.com/internetarchive/archive-hocr-tools/pull/23
    rev = "e2d3dc1bb9aec92b72e6d7db8757af730626e009";
    hash = "sha256-iFKtk+9wbLXO67pzowv5R87LZ3w8CuL95IwcscKY5Tc=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    ebooklib
    pillow
    python-fontconfig
    tqdm
    psutil
    numpy
    doxapy
  ];

  pythonImportsCheck = [ "hocr" ];

  meta = with lib; {
    description = "Efficient hOCR tooling";
    homepage = "https://github.com/internetarchive/archive-hocr-tools";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
