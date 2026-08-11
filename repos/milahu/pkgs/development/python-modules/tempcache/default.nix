{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  build,
  cloudpickle,
  invoke,
  pytest,
  toml,
  twine,
}:

buildPythonPackage rec {
  pname = "tempcache";
  version = "0.0.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "furechan";
    repo = "tempcache";
    rev = version;
    hash = "sha256-VPYmTQeFClMvmjiJoobi98RmNbRGccc8Rq9kOZD+pRo=";
  };

  build-system = [
    hatchling
  ];

  optional-dependencies = {
    dev = [
      build
      cloudpickle
      invoke
      pytest
      toml
      twine
    ];
  };

  pythonImportsCheck = [
    "tempcache"
  ];

  meta = {
    description = "Python caching using temporary files";
    homepage = "https://github.com/furechan/tempcache";
    changelog = "https://github.com/furechan/tempcache/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
}
