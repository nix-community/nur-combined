{
  lib,
  python3,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "pathspec";
  version = "v1.1.1";
  sha256 = "sha256-07DCg5FErd76/WLZxt7OsapqX1Dhn6EjFTLVYyJgC1Y=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;


  src = fetchFromGitHub {
    owner = "cpburnz";
    repo = "python-pathspec";
    rev = version;
    inherit sha256;
  };

  meta = {
    description = "Utility library for gitignore style pattern matching of file paths.";
    homepage = "https://github.com/cpburnz/python-pathspec";
    license = lib.licenses.AND [ lib.licenses.mpl20 lib.licenses.mit ];
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };

  pyproject = true;

  build-system = with python.pkgs; [ flit-core ];
}