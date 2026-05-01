{
  lib,
  buildPythonPackage,
  setuptools,
  pillow,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "openpyxl-image-loader";
  version = "1.0.5";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-bZ1/pcNawKPmILnq9zNEIKdpPM2yoW6UCjqSvD7If+g=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    pillow
  ];

  pythonImportsCheck = [
    "openpyxl_image_loader"
  ];

  meta = {
    description = "Openpyxl wrapper that gets images from cells";
    homepage = "https://pypi.org/project/openpyxl-image-loader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "openpyxl-image-loader";
  };
})
