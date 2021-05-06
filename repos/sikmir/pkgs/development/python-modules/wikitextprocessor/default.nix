{ lib, python3Packages, fetchFromGitHub, lru-dict }:

python3Packages.buildPythonApplication rec {
  pname = "wikitextprocessor";
  version = "0.4.94";

  src = fetchFromGitHub {
    owner = "tatuylonen";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-eRtTgi519j5rHJL4xMN91gCMlpwgVhWNEIKqBfdkQGo=";
  };

  propagatedBuildInputs = with python3Packages; [ lupa dateparser lru-dict ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "Parser and expander for Wikipedia, Wiktionary etc. dump files, with Lua execution support";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
