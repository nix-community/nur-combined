{
  lib,
  python3,
  fetchFromGitHub,
  buildPythonApplication,
  setuptools,
  wheel,
  pillow,
  pyside6,
  tree-sitter,
  tree-sitter-language-pack,
}:

buildPythonApplication rec {
  pname = "hocr-editor-qt";
  version = "unstable-2025-10-25";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "hocr-editor-qt";
    rev = "af66949994a67f215c220229ceb40c3a856aeba7";
    hash = "sha256-VhG4Qt1qrlbHP8wtsY8yD4vsJE04gD5r/9OzbrptAg8=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    pillow
    pyside6
    tree-sitter
    tree-sitter-language-pack
  ];

  pythonImportsCheck = [
  ];

  meta = {
    description = "Graphical HOCR editor to produce minimal diffs for proofreading of tesseract OCR output";
    homepage = "https://github.com/milahu/hocr-editor-qt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "hocr-editor-qt";
  };
}
