{
  lib,
  fetchPypi,
  buildPythonPackage,
  setuptools,
  wheel,
  pygments,
  rich,
  rich-click,
  click,
  pyyaml,
  esp-pylib,
}:

buildPythonPackage rec {
  pname = "pyclang";
  version = "0.7.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-s9SHh7tnSJFk0G7wNDMo1lGDG0Xw62fg/skiHvompfU=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    esp-pylib
    rich
    rich-click
    click
    pyyaml
  ];

  passthru.optional-dependencies = {
    html = [
      pygments
      setuptools
    ];
  };

  pythonImportsCheck = [ "pyclang" ];

  meta = {
    description = "Python clang-tidy runner";
    homepage = "https://pypi.org/project/pyclang/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "idf_clang_tidy";
  };
}
