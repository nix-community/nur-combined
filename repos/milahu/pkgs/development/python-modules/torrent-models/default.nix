{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pdm-backend,
  bencode-rs,
  pydantic,
  rich,
  tqdm,
  typing-extensions,
  click,
  humanize,
  black,
  mypy,
  ruff,
  sphinx-autobuild,
  torrent-models,
  types-tqdm,
  # autodoc-pydantic,
  furo,
  myst-nb,
  myst-parser,
  sphinx,
  sphinx-click,
  sphinx-design,
  # sphinxcontrib-mermaid,
  libtorrent,
  pytest,
  pytest-codspeed,
  pytest-cov,
  # pytest-profiling,
  torf,
}:

buildPythonPackage rec {
  pname = "torrent-models";
  version = "0.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "p2p-ld";
    repo = "torrent-models";
    rev = "v${version}";
    hash = "sha256-C+qWk5Gq7E79DzPl2O5HzvVoXO8EO+cJS5EotCZ+u0s=";
  };

  build-system = [
    pdm-backend
  ];

  dependencies = [
    bencode-rs
    pydantic
    rich
    tqdm
    typing-extensions
    humanize
  ];

  optional-dependencies = {
    cli = [
      click
    ];
    dev = [
      black
      mypy
      ruff
      sphinx-autobuild
      torrent-models
      types-tqdm
    ];
    docs = [
      # autodoc-pydantic
      furo
      myst-nb
      myst-parser
      rich
      sphinx
      sphinx-click
      sphinx-design
      # sphinxcontrib-mermaid
      torrent-models
    ];
    libtorrent = [
      libtorrent
    ];
    mypy = [
      torrent-models
      types-tqdm
    ];
    tests = [
      pytest
      pytest-codspeed
      pytest-cov
      # pytest-profiling
      torf
      # torrent-models[cli,libtorrent]
      libtorrent
      click
    ];
  };

  nativeCheckInputs = [
    pytest
    pytest-codspeed
    pytest-cov
    # pytest-profiling
    torf
    # torrent-models[cli,libtorrent]
    libtorrent
    click
  ];

  pythonImportsCheck = [
    "torrent_models"
  ];

  # fix: ModuleNotFoundError: No module named 'libtorrent'
  pytestCheckPhase = ":";

  meta = {
    description = "Torrent file parsing and creation with pydantic";
    homepage = "https://github.com/p2p-ld/torrent-models";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ ];
  };
}
