{
  lib,
  stdenv,
  python3Packages,
  fetchFromGitHub,
  fetchurl,
  unzip,
  wikitextprocessor,
}:

let
  brown = fetchurl {
    url = "https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/brown.zip";
    hash = "sha256-mydfmzuV171mzPt80ln0RaE7vl0fQQeroJ/T6DZLr6Y=";
  };
in
python3Packages.buildPythonApplication {
  pname = "wiktextract";
  version = "1.99.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = "wiktextract";
    rev = "3a3e5746305cf648a0386e089615aa533f68b66d";
    hash = "sha256-iL3mFxX32OaD8UdPdvMyc/ksmeCH4iykM37DgHd+KwE=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail python-Levenshtein Levenshtein
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    levenshtein
    setuptools
    wikitextprocessor
    nltk
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    unzip
  ];

  # https://www.nltk.org/data.html#manual-installation
  preCheck = ''
    export NLTK_DATA=$PWD/nltk_data
    mkdir -p nltk_data/corpora
    unzip ${brown} -d nltk_data/corpora
  '';

  meta = {
    description = "Wiktionary dump file parser and multilingual data extractor";
    homepage = "https://github.com/tatuylonen/wiktextract";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
