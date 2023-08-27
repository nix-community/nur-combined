{ lib
, buildPythonPackage
, fetchFromGitHub
, feedparser
, pdoc
, pip-audit
, ruff
, setuptools
}:


let
  pname = "arxiv-py";
  version = "1.4.8";
in
buildPythonPackage {
  inherit pname version;
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "lukasschwab";
    repo = "arxiv.py";
    rev = "${version}";
    hash = "sha256-Sq2Vj0rwFNORADKPSNiFH0hQLskOOmMBe44O7/fGrBo=";
  };

  # requirements.txt contain dev dependencies after a comment, let's delete them
  postPatch = ''
    sed -ni '/Development/q;p' requirements.txt
  '';

  # Needs network
  dontUseSetuptoolsCheck = true;

  nativeBuildInputs = [
    setuptools
  ];

  # Skipping pytest because network access
  nativeCheckInputs = [
    pdoc
    pip-audit
    ruff
  ];

  propagatedBuildInputs = [
    feedparser
  ];

  pythonImportsCheck = [ "arxiv" ];

  meta = with lib; {
    description = "Python wrapper for the arXiv API";
    homepage = "https://github.com/lukasschwab/arxiv.py";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
