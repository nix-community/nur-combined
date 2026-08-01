{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "llm-aided-ocr";
  version = "0-unstable-2026-08-01";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "llm_aided_ocr";
    # https://github.com/Dicklesworthstone/llm_aided_ocr/pull/25
    rev = "85043c8e6cc85ee8207120a7c97d12d879f79cba";
    hash = "sha256-Wv5XotMZ1NGq0osZwxqTqMJAaHhB1CCoLsvTspTcAKs=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    anthropic
    filelock
    langdetect
    llama-cpp-python
    numpy
    nvgpu
    openai
    opencv-python-headless
    pdf2image
    pillow
    pytesseract
    python-decouple
    scikit-learn
    tiktoken
    transformers
  ];

  pythonImportsCheck = [
    "llm_aided_ocr"
  ];

  meta = {
    description = "Enhances Tesseract OCR output using LLMs (local or API) for error correction, smart chunking, and markdown formatting of scanned PDFs";
    homepage = "https://github.com/Dicklesworthstone/llm-aided-ocr";
    changelog = "https://github.com/Dicklesworthstone/llm-aided-ocr/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "llm-aided-ocr";
  };
})
