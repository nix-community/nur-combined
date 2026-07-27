{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, wheel
, numpy
, pycocotools
}:

buildPythonPackage rec {
  pname = "pycocoevalcap";
  version = "1.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "salaniz";
    repo = "pycocoevalcap";
    rev = "v${version}";
    hash = "sha256-LcMcxRF8IVu7t05GXVXKzsFBxdP+LllfuV3vCGNdYvk=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    numpy
    pycocotools
  ];

  pythonImportsCheck = [
    "pycocoevalcap.eval"
  ];

  meta = with lib; {
    description = "Python 3 support for the MS COCO caption evaluation tools";
    homepage = "https://github.com/salaniz/pycocoevalcap";
    license = licenses.bsd2WithViews;
    maintainers = with maintainers; [ ];
  };
}
