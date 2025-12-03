{ python3, fetchFromGitHub }:
let
  python = python3;
in
python.pkgs.buildPythonPackage {
  pname = "borghash";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "borgbackup";
    repo = "borghash";
    tag = "0.1.0";
    hash = "sha256-jyiPdMte8lXv35179blEQwyBQ8tsdaRaCagFj6I8F2s=";
  };

  build-system = with python.pkgs; [
    setuptools-scm
    cython
  ];
}
