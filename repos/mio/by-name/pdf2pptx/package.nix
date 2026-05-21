{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pdf2pptx";
  version = "1.0.5";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-DNYNF/4LDgZlcPCRVl7afMhxY97rN5mOw3H4NnZlmos=";
  };

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [ python3Packages.pythonRelaxDepsHook ];
  pythonRelaxDeps = [ "pymupdf" ];

  dependencies = with python3Packages; [
    click
    pymupdf
    python-pptx
    tqdm
  ];

  pythonImportsCheck = [ "pdf2pptx" ];

  meta = {
    description = "Utility to convert a PDF slideshow to PowerPoint PPTX";
    homepage = "https://github.com/kevinmcguinness/pdf2pptx";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "pdf2pptx";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
