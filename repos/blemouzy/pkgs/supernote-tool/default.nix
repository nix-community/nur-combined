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
  version = "0.7.0";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "jya-dev";
    repo = "supernote-tool";
    tag = "v${version}";
    hash = "sha256-WW5saMJgTWr8I4dh5MWK/U1y4C7Ugf2zIFQ12bEacGA=";
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
