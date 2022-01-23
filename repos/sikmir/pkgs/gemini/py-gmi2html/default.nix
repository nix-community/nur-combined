{ lib, fetchFromGitea, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gmi2html";
  version = "2022-01-19";

  src = fetchFromGitea {
    domain = "notabug.org";
    owner = "tinyrabbit";
    repo = pname;
    rev = "1a63bc609915a3b1531e6ba4a5893f00743ac0e0";
    hash = "sha256-FVT28QYfSaVOI8qbxQbZ2w+dktg1tpp6eb4IltEpltU=";
  };

  meta = with lib; {
    description = "A library and CLI tool for converting text/gemini to text/html";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
