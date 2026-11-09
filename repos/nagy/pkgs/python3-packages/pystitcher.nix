{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  setuptools-scm,
  html5lib,
  validators,
  markdown,
  pypdf3,
  wheel,
}:

buildPythonApplication (finalAttrs: {
  pname = "pystitcher";
  version = "1.0.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "captn3m0";
    repo = "pystitcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JI0gQh05zrrJSUnlDt0e3mG/VoFrzJzvL7JJzSD+2Q8=";
  };

  build-system = [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = [
    html5lib
    validators
    markdown
    pypdf3
  ];

  pythonImportsCheck = [ "pystitcher" ];

  meta = {
    description = "Stitches your PDF files together, generating nice customizable bookmarks for you using a declarative markdown file as input";
    homepage = "https://github.com/captn3m0/pystitcher";
    changelog = "https://github.com/captn3m0/pystitcher/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
