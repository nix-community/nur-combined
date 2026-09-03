{
  lib,
  setuptools,
  buildPythonPackage,
  fetchFromGitHub,
  numpy,
  pandas,
  polars,
}:

buildPythonPackage (finalAttrs: {
  pname = "mintalib";
  version = "0.1.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "furechan";
    repo = "mintalib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8u9l8vIoq2FFeJVbm0ZRWSFtEfTL4Gw6za7gNYpjSbA=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
  ];

  optional-dependencies = {
    pandas = [
      pandas
    ];
    polars = [
      polars
    ];
  };

  pythonImportsCheck = [
    "mintalib"
  ];

  meta = {
    description = "Minimal Technical Analysis Library for Python";
    homepage = "https://github.com/furechan/mintalib";
    changelog = "https://github.com/furechan/mintalib/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
