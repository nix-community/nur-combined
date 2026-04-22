{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  einops,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "conformer";
  version = "0.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "lucidrains";
    repo = "conformer";
    tag = finalAttrs.version;
    hash = "sha256-ibHlDFgWm9iW2VOYMrXssPPW2jNqnjqKo3B6wrc7cmM=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    einops
    torch
  ];

  pythonImportsCheck = [
    "conformer"
  ];

  meta = {
    description = "Implementation of the convolutional module from the Conformer paper, for use in Transformers";
    homepage = "https://github.com/lucidrains/conformer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
  };
})
