{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "epub-meta";
  version = "0.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "paulocheque";
    repo = "epub-meta";
    tag = finalAttrs.version;
    hash = "sha256-d4R/cwufWUk6qMsn4ANFz7NUi9aFpWB3nFue5DmaZpI=";
  };

  build-system = [
    setuptools
  ];

  pythonImportsCheck = [
    "epub_meta"
  ];

  meta = {
    description = "Small Python library to read metadata information from an ePub (2 and 3) file";
    homepage = "https://github.com/paulocheque/epub-meta";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
  };
})
