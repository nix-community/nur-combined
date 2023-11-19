# based on nixpkgs/pkgs/development/python-modules/argostranslate/default.nix

/*
  https://github.com/argosopentech/argos-translate/tree/v2#argos-translate-2-beta

  Argos Translate 2 beta

  A beta version of Argos Translate 2 is available
  to install from source from the v2 branch on GitHub.
  Argos Translate 2 has a multilingual model architecture,
  more extensive unit testing, and a more experimental orientation.
*/

{ lib
, buildPythonPackage
, fetchFromGitHub
, pytestCheckHook
, ctranslate2
, ctranslate2-cpp
, sentencepiece
, stanza
, python
}:
let
  ctranslate2OneDNN = ctranslate2.override {
    ctranslate2-cpp = ctranslate2-cpp.override {
      # https://github.com/OpenNMT/CTranslate2/issues/1294
      withOneDNN = true;
      withOpenblas = false;
    };
  };
in
buildPythonPackage rec {
  pname = "argostranslate";
  # setup.py: version="2.alpha"
  version = "2.alpha";

  format = "setuptools";

  # https://github.com/argosopentech/argos-translate/tree/v2
  src = fetchFromGitHub {
    owner = "argosopentech";
    repo = "argos-translate";
    rev = "39cc641943851544dc1ad8220bde06f1b9a2eadb";
    sha256 = "sha256-iD1y3GOPMWAPpmMuznSt1kTLjHhDkpcwK3YtKd6W2EE=";
  };

  propagatedBuildInputs = [
    ctranslate2OneDNN
    sentencepiece
    stanza
  ];

  postPatch = ''
    substituteInPlace requirements.txt  \
      --replace "==" ">="
  '';

  postInstall = ''
    echo ${version} >$out/${python.sitePackages}/argostranslate/__version__
  '';

  doCheck = false; # needs network access

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # required for import check to work
  # PermissionError: [Errno 13] Permission denied: '/homeless-shelter'
  env.HOME = "/tmp";

  pythonImportsCheck = [
    "argostranslate"
    "argostranslate.translate"
  ];

  meta = with lib; {
    description = "Open-source offline translation library written in Python";
    homepage = "https://www.argosopentech.com";
    license = licenses.mit;
    maintainers = with maintainers; [ misuzu ];
  };
}
