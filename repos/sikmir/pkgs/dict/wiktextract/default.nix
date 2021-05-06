{ lib, python3Packages, fetchFromGitHub, wikitextprocessor }:

python3Packages.buildPythonApplication rec {
  pname = "wiktextract";
  version = "1.99.5";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-am926XGY2XlJXVqVQyfWvFhiOkanuSXpq07ckPChnpU=";
  };

  propagatedBuildInputs = with python3Packages; [ python-Levenshtein setuptools wikitextprocessor ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Wiktionary dump file parser and multilingual data extractor";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
