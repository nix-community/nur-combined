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
  version = "0.1.13";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "furechan";
    repo = "mintalib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/HYIXXIvEHTHbblB8Wvyi0HENZAfgrzYyYUvmnoOCrw=";
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
