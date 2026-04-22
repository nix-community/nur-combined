{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  docker,
  grpcio,
  packaging,
  protobuf,
  pydantic,
  pyyaml,
  requests,
  rich,
  black,
  build,
  flaky,
  furo,
  grpcio-tools,
  isort,
  mypy,
  myst-parser,
  petname,
  pytest,
  pytest-sphinx,
  ruff,
  sphinx,
  sphinx-autobuild,
  sphinx-autodoc-typehints,
  sphinx-copybutton,
  sphinx-inline-tabs,
  twine,
  types-cachetools,
  types-protobuf,
  types-pyyaml,
  types-requests,
}:

buildPythonPackage rec {
  pname = "beaker-py";
  version = "1.38.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "allenai";
    repo = "beaker-py";
    rev = "v${version}";
    hash = "sha256-KdRTPuxVyrNjXSdu3kSMMq1bjb96e2MeaO7GlbfC67Q=";
  };

  postPatch = ''
    sed -i -E 's/"rich>=.+",/"rich",/' pyproject.toml
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    docker
    grpcio
    packaging
    protobuf
    pydantic
    pyyaml
    requests
    rich
  ];

  optional-dependencies = {
    dev = [
      black
      build
      flaky
      furo
      grpcio-tools
      isort
      mypy
      myst-parser
      packaging
      petname
      pytest
      pytest-sphinx
      ruff
      setuptools
      sphinx
      sphinx-autobuild
      sphinx-autodoc-typehints
      sphinx-copybutton
      sphinx-inline-tabs
      twine
      types-cachetools
      types-protobuf
      types-pyyaml
      types-requests
      wheel
    ];
  };

  pythonImportsCheck = [
    "beaker"
  ];

  meta = {
    description = "A pure-Python Beaker client";
    homepage = "https://github.com/allenai/beaker-py";
    changelog = "https://github.com/allenai/beaker-py/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}
