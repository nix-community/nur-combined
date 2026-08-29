{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  nix-update-script,
  setuptools,
  pymupdf,
}:

buildPythonApplication (finalAttrs: {
  pname = "pdf-toc";
  version = "1.2.0";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "HareInWeed";
    repo = "pdf-toc";
    # tag = "v${finalAttrs.version}";
    # https://github.com/HareInWeed/pdf-toc/pull/6
    # move to src/pdf_toc
    rev = "444fa7083749eaf0b2451d1921b455333bacf44f";
    hash = "sha256-BMS1ac1zrlg80462UxtR34W8TgP5sTwoP00IHDTrkos=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    pymupdf
  ];

  pythonImportsCheck = [
    "pdf_toc"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A CLI tool to extract or edit the Table Of Contents of PDF files";
    homepage = "https://github.com/HareInWeed/pdf-toc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "pdf-toc";
  };
})
