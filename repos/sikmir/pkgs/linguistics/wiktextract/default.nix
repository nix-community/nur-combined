{ lib, stdenv, python3Packages, fetchFromGitHub, fetchurl, unzip, wikitextprocessor }:

let
  brown = fetchurl {
    url = "https://raw.githubusercontent.com/nltk/nltk_data/gh-pages/packages/corpora/brown.zip";
    hash = "sha256-mydfmzuV171mzPt80ln0RaE7vl0fQQeroJ/T6DZLr6Y=";
  };
in
python3Packages.buildPythonApplication rec {
  pname = "wiktextract";
  version = "1.99.7";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = pname;
    rev = "3a3e5746305cf648a0386e089615aa533f68b66d";
    hash = "sha256-iL3mFxX32OaD8UdPdvMyc/ksmeCH4iykM37DgHd+KwE=";
  };

  propagatedBuildInputs = with python3Packages; [ python-Levenshtein setuptools wikitextprocessor nltk ];

  checkInputs = with python3Packages; [ pytestCheckHook unzip ];

  # https://www.nltk.org/data.html#manual-installation
  preCheck = ''
    export NLTK_DATA=$PWD/nltk_data
    mkdir -p nltk_data/corpora
    unzip ${brown} -d nltk_data/corpora
  '';

  meta = with lib; {
    description = "Wiktionary dump file parser and multilingual data extractor";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
