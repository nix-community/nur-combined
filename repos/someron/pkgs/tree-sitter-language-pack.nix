{
  python3,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "tree-sitter-language-pack";
  version = "v1.8.1";
  sha256 = "sha256-UA0s6HmnMPx0FUH9ZBb0L5Zp07duw+Fd25hTotE+d/0=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;


  src = fetchFromGitHub {
    owner = "kreuzberg-dev";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  pyproject = true;

  build-system = with python.pkgs; [
    hatchling
  ];
}