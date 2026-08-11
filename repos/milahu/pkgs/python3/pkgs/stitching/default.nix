{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  largestinteriorrectangle,
  opencv-python,
  requests,
}:

buildPythonApplication rec {
  pname = "stitching";
  version = "0.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OpenStitching";
    repo = "stitching";
    rev = "v${version}";
    hash = "sha256-kCpt/Rt2UJqHJP9l/UxHupjuWPnVRgGJMDnNF4hdkCk=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    largestinteriorrectangle
    opencv-python
    requests
  ];

  pythonImportsCheck = [
    "stitching"
  ];

  meta = {
    description = "A Python package for fast and robust Image Stitching";
    homepage = "https://github.com/OpenStitching/stitching";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "stitch";
  };
}
