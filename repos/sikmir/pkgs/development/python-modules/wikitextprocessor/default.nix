{ lib, stdenv, python3Packages, fetchFromGitHub, lru-dict }:

python3Packages.buildPythonApplication rec {
  pname = "wikitextprocessor";
  version = "2021-09-10";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = pname;
    rev = "29ae764a226a941664e12bef0ae1f376c6d84f48";
    hash = "sha256-BkHPds0fSzbSKnPDOo5IuXixsOmNMD2YKx8EetglcB0=";
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
