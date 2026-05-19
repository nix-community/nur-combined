{
  python3,
  fetchFromGitHub,
}:
let
  python = python3;
  pname = "model2vec";
  version = "v0.8.1";
  sha256 = "sha256-K2ys+BgiEjipBS40szK0yng7P5yN2dFardoCoRDcILU=";
in
python.pkgs.buildPythonPackage {
  inherit pname version;


  src = fetchFromGitHub {
    owner = "MinishLab";
    repo = pname;
    rev = version;
    inherit sha256;
  };

  pyproject = true;

  build-system = with python.pkgs; [
    setuptools
    setuptools-scm

    rich
  ];

  dependencies = with python.pkgs; [
    jinja2
    joblib
    numpy
    safetensors
    tokenizers
    tqdm
  ];
}