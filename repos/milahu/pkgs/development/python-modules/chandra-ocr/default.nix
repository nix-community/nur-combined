{
  lib,
  python3,
  fetchFromGitHub,
  torch,
  torchvision,
  accelerate,
  # flash-linear-attention,
  # causal-conv1d,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "chandra-ocr";
  version = "0.2.0-a527ad3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "datalab-to";
    repo = "chandra";
    # tag = "v${finalAttrs.version}";
    # https://github.com/datalab-to/chandra/pull/99
    rev = "a527ad36ee4ebab28cf1cd528dbd4199c519a005";
    hash = "sha256-erUSiT3uh9hQsMzDU3wNV8ae6VqtGnDB/tElWAXfcDQ=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/^(\s+"[a-zA-Z0-9_-]+)(==|>=)[0-9.]+(,<[0-9.]+)?"/\1"/' pyproject.toml
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    click
    filetype
    markdownify
    openai
    pillow
    pydantic
    pydantic-settings
    pypdfium2
    python-dotenv
    six
  ];

  optional-dependencies = with python3.pkgs; {
    all = [
      chandra-ocr
    ];
    app = [
      streamlit
    ];
    hf = [
      accelerate
      torch
      torchvision
      transformers

      # no. UserWarning: causal_conv1d was requested, but nvcc was not found.
      # Are you sure your environment has nvcc available?
      # If you're installing within a container from https://hub.docker.com/r/pytorch/pytorch,
      # only images whose names contain 'devel' will provide nvcc.
      #
      # fix: The fast path is not available because one of the required library is not installed. Falling back to torch implementation.
      # To install follow https://github.com/fla-org/flash-linear-attention#installation and https://github.com/Dao-AILab/causal-conv1d
      #
      # flash-linear-attention
      # causal-conv1d
    ];
  };

  pythonImportsCheck = [
    "chandra"
  ];

  meta = {
    description = "OCR model that handles complex tables, forms, handwriting with full layout";
    homepage = "https://github.com/datalab-to/chandra";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "chandra";
  };
})
