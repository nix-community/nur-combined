{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  wheel,
  markdown,
  lib3to6,
  pathlib2,
}:

buildPythonPackage rec {
  pname = "markdown-katex";
  version = "202406.1035";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6C97+ahTZFHajwF2jYR1FvoYJ/6xcUC46qC+qYJr2rA=";
  };

  doCheck = false;

  dependencies = [
    markdown
    lib3to6
    pathlib2
  ];

  pyproject = true;
  build-system = [
    setuptools
    wheel
  ];

  meta = {
    description = "Adds KaTeX support for Python Markdown";
    homepage = "https://github.com/mbarkhau/markdown-katex";
    changelog = "https://github.com/mbarkhau/markdown-katex/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
}
