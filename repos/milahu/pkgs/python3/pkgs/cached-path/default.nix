{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  boto3,
  filelock,
  google-cloud-storage,
  huggingface-hub,
  packaging,
  requests,
  rich,
  beaker-py,
  black,
  build,
  flaky,
  furo,
  isort,
  mypy,
  myst-parser,
  pytest,
  responses,
  ruff,
  sphinx,
  sphinx-autobuild,
  sphinx-autodoc-typehints,
  sphinx-copybutton,
  twine,
  types-requests,
}:

buildPythonPackage rec {
  pname = "cached-path";
  version = "1.8.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "allenai";
    repo = "cached_path";
    rev = "v${version}";
    hash = "sha256-jIu+A+ZDCrX/KyUSWYjm4wfTQt6cle50yf+BM6PRLNw=";
  };

  postPatch = ''
    sed -i -E 's/"rich>=.+",/"rich",/' pyproject.toml
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    boto3
    filelock
    google-cloud-storage
    huggingface-hub
    packaging
    requests
    rich
  ];

  optional-dependencies = {
    dev = [
      beaker-py
      black
      build
      flaky
      furo
      isort
      mypy
      myst-parser
      pytest
      responses
      ruff
      setuptools
      sphinx
      sphinx-autobuild
      sphinx-autodoc-typehints
      sphinx-copybutton
      twine
      types-requests
      wheel
    ];
  };

  pythonImportsCheck = [
    "cached_path"
  ];

  meta = {
    description = "A file utility for accessing both local and remote files through a unified interface";
    homepage = "https://github.com/allenai/cached_path";
    changelog = "https://github.com/allenai/cached_path/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
