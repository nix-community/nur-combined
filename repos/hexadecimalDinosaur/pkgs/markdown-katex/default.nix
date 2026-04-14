{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  markdown,
  lib3to6,
  pathlib2,
  pytestCheckHook,
  beautifulsoup4,
  katex
}:

let
  os = lib.toSentenceCase (builtins.elemAt (lib.splitString "-" stdenv.hostPlatform.system) 1);
  os_str = "${stdenv.hostPlatform.ubootArch}-${os}";
in
buildPythonPackage rec {
  pname = "markdown-katex";
  version = "202406.1035";

  src = fetchFromGitHub {
    owner = "mbarkhau";
    repo = "markdown-katex";
    tag = "v${version}";
    hash = "sha256-RbulnQGbOF1je+4DlVWOOMHcBpYRLorqIG/qpi3ww90=";
  };

  postPatch = ''
    rm src/markdown_katex/bin/*
    ln -s ${katex.out}/bin/katex src/markdown_katex/bin/katex_${os_str}
  '';

  dependencies = [
    markdown
    lib3to6
    pathlib2
    katex
  ];

  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];

  nativeCheckInputs = [
    pytestCheckHook
    beautifulsoup4
  ];
  disabledTestPaths = [
    "scripts/exit_0_if_empty.py"
  ];
  disabledTests = [
    "test_bin_paths"
  ];

  pythonImportsCheck = [ "markdown_katex" ];

  meta = {
    description = "Adds KaTeX support for Python Markdown";
    homepage = "https://github.com/mbarkhau/markdown-katex";
    changelog = "https://github.com/mbarkhau/markdown-katex/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
