# FIXME joined lines, and shifted following lines
# https://github.com/ahnafnafee/local-llm-pdf-ocr/issues/2
# possible solution: downgrade to opencv 4.11.0
# https://lazamar.co.uk/nix-versions/?package=opencv&version=4.11.0&fullName=opencv-4.11.0&keyName=opencv&revision=e6f23dc08d3624daab7094b701aa3954923c6bbb&channel=nixpkgs-unstable#instructions
# nix-shell -p opencv -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz

# TODO dont depend on local LLM server
# also offer a standalone tool like
# https://github.com/BartWojtowicz/videopython

# TODO test FastAPI web server: pdf_ocr.server

{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "local-llm-pdf-ocr";
  version = "0-unstable-2026-04-29-03a4dfd";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ahnafnafee";
    repo = "local-llm-pdf-ocr";
    # https://github.com/ahnafnafee/local-llm-pdf-ocr/pull/5
    rev = "03a4dfd414bf2afec0f1eafa1ea6ff441d7daf7a";
    hash = "sha256-9rPaJyLxdb1ZQ9uRFkXF1JNtnpe78nBEqQDi+bE1Gz8=";
  };

  postPatch = ''
    # unpin dependencies
    sed -i -E 's/>=.*",$/",/' pyproject.toml
  '';

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    fastapi
    openai
    opencv-python-headless
    pillow
    pymupdf
    python-dotenv
    python-multipart
    rich
    surya-ocr
    torch
    torchvision
    tqdm
    uvicorn
    websockets
  ];

  pythonImportsCheck = [
    "pdf_ocr"
  ];

  # doCheck = false;
  dontUsePytestCheck = true;

  meta = {
    description = "Convert scanned PDFs into searchable text locally using Vision LLMs (olmOCR)";
    homepage = "https://github.com/ahnafnafee/local-llm-pdf-ocr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "local-llm-pdf-ocr";
  };
})
