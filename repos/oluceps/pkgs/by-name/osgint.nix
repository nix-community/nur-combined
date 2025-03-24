{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "osgint";
  version = "feb5";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "hippiiee";
    repo = "osgint";
    rev = "c20724fc2847e9ae1a8a837c54288fb5ac08e16e";
    hash = "sha256-/ZI+HPkRmIiUWdxRvqRHvK33sUizaxNisnAfjbCHiqQ=";
  };

  # build-system = with python3Packages; [
  #   # setuptools
  # ];

  dependencies = with python3Packages; [
    requests
    # argparse
  ];
  installPhase = ''install -Dm755 osgint.py $out/bin/osgint'';

  meta = {
  };
}
