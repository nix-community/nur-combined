{ lib, stdenv, python3Packages, fetchFromGitHub, lru-dict }:

python3Packages.buildPythonPackage rec {
  pname = "wikitextprocessor";
  version = "0.4.96";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = "wikitextprocessor";
    rev = "3fa4cb9418e05d1d462a53d629848196b7ade492";
    hash = "sha256-cjhKgzqsPwVO2/fwC62IDilMhz6fg6qQrnm0xLQ3KPk=";
  };

  propagatedBuildInputs = with python3Packages; [ lupa dateparser lru-dict ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  disabledTests = [
    "test_string_format2"
  ] ++ lib.optionals stdenv.isDarwin [
    "test_long_twothread"
    "test_expr29"
  ];

  meta = with lib; {
    description = "Parser and expander for Wikipedia, Wiktionary etc. dump files, with Lua execution support";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
