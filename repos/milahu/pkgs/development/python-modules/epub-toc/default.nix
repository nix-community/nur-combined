{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "epub-toc";
  version = "0-unstable-2026-07-04";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "almazom";
    repo = "epub_toc";
    # https://github.com/almazom/epub_toc/pull/1
    rev = "15a9acf41f6e62b08ef1cb296e3d9b52e1cb6efc";
    hash = "";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    ebooklib
    epub-meta
    lxml
    tika
  ];

  pythonImportsCheck = [
    "epub_toc"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/almazom/epub_toc";
    changelog = "https://github.com/almazom/epub_toc/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "epub_toc";
  };
})
