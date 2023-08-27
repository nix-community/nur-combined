{ lib
, buildPythonPackage
, fetchFromGitHub
, feedparser
, pdoc
, flake8
, pytestCheckHook
}:


let
  pname = "arxiv.py";
  version = "1.4.8";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "lukasschwab";
    repo = pname;
    rev = "${version}";
    hash = "sha256-Sq2Vj0rwFNORADKPSNiFH0hQLskOOmMBe44O7/fGrBo=";
  };

  # requirements.txt contain dev dependencies after a comment, let's delete them
  postPatch = ''
    sed -ni '/Development/q;p' requirements.txt
  '';

  # Needs network
  dontUseSetuptoolsCheck = true;

  propagatedBuildInputs = [
    feedparser
  ];
}
