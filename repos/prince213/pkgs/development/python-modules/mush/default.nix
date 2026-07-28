{
  lib,
  buildPythonPackage,
  fetchFromGitHub,

  # build-system
  setuptools,

  # nativeCheckInputs
  pytestCheckHook,
  mock,
  sybil,
  testfixtures,
}:

buildPythonPackage (finalAttrs: {
  pname = "mush";
  version = "2.8.1";
  pyproject = true;

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "simplistix";
    repo = "mush";
    tag = finalAttrs.version;
    hash = "sha256-IaoaxQ4cg2UybWQezF8CxTYwNyXxWzH4nHUnP/v77fE=";
  };

  patches = [
    ./get_annotations.patch
    ./pytest_collect_file.patch
    ./pytest_ignore_collect.patch
    ./sybil.patch
  ];

  build-system = [ setuptools ];

  pythonImportsCheck = [ "mush" ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
    sybil
    testfixtures
  ];

  preCheck = ''
    rm -r build
  '';

  meta = {
    description = "Type-based dependency injection for scripts";
    homepage = "https://github.com/simplistix/mush";
    downloadPage = "https://github.com/simplistix/mush/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
