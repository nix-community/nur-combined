{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "olmocr";
  version = "0.4.25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "allenai";
    repo = "olmocr";
    rev = "v${version}";
    hash = "sha256-kek+nzO6FVAhCNSqJE251POdk4ZAGWhGY8BdKXEYFZI=";
  };

  postPatch = ''
    sed -i -E 's/"transformers==.*",/"transformers",/' pyproject.toml
  '';

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    beaker-py
    bleach
    boto3
    cached-path
    cryptography
    filelock
    ftfy
    httpx
    lingua-language-detector
    markdown2
    markdownify
    orjson
    pillow
    pypdf
    pypdfium2
    requests
    smart-open
    torch
    transformers
    zstandard
  ];

  optional-dependencies = with python3.pkgs; {
    bench = [
      anthropic
      flask
      fuzzysearch
      google-genai
      lxml
      mistralai
      openai
      playwright
      rapidfuzz
      sequence-align
      syntok
      tinyhost
    ];
    dev = [
      black
      build
      datasets
      furo
      isort
      mypy
      myst-parser
      necessary
      omegaconf
      packaging
      peft
      pytest
      pytest-asyncio
      pytest-cov
      pytest-sphinx
      ruff
      setuptools
      spacy
      sphinx
      sphinx-autobuild
      sphinx-autodoc-typehints
      sphinx-copybutton
      trl
      twine
      wandb
      wheel
    ];
    elo = [
      matplotlib
      numpy
      pandas
      scipy
    ];
    gpu = [
      vllm
    ];
    train = [
      accelerate
      augraphy
      einops
      omegaconf
      peft
      torch
      torchvision
      trl
      wandb
    ];
  };

  pythonImportsCheck = [
    "olmocr"
  ];

  meta = {
    description = "Toolkit for linearizing PDFs for LLM datasets/training";
    homepage = "https://github.com/allenai/olmocr";
    changelog = "https://github.com/allenai/olmocr/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "olmocr";
  };
}
