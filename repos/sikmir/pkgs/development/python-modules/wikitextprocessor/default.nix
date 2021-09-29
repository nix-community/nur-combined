{ lib, stdenv, python3Packages, fetchFromGitHub, lru-dict }:

python3Packages.buildPythonApplication rec {
  pname = "wikitextprocessor";
  version = "0.4.95";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-YLlgjMGIifymdQfsZKnf3aRsMIyA35X/sQSqNj5t1TM=";
  };

  propagatedBuildInputs = with python3Packages; [ lupa dateparser lru-dict ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = lib.optionals stdenv.isDarwin [
    "test_long_twothread"
    "test_expr29"
  ];

  meta = with lib; {
    description = "Parser and expander for Wikipedia, Wiktionary etc. dump files, with Lua execution support";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
