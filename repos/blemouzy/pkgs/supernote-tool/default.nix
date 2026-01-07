{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  pythonOlder,
  setuptools,
  hatchling,
  colour,
  fusepy,
  numpy,
  pillow,
  potracer,
  pypng,
  reportlab,
  svglib,
  svgwrite,
}:

buildPythonApplication rec {
  pname = "supernote-tool";
  version = "0.6.3";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "jya-dev";
    repo = "supernote-tool";
    rev = "v${version}";
    hash = "sha256-fU5yuMi8x5C1Ku7XICpl9VtJ3SGNRHpx9Ql32k6VQ0Y=";
  };

  nativeBuildInputs = [
    setuptools
    hatchling
  ];

  propagatedBuildInputs = [
    colour
    fusepy
    numpy
    pillow
    potracer
    pypng
    reportlab
    svglib
    svgwrite
  ];

  meta = {
    description = "Unofficial python tool for Supernote";
    homepage = "https://github.com/jya-dev/supernote-tool";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jfvillablanca ];
    mainProgram = "supernote-tool";
    platforms = lib.platforms.all;
  };
}
