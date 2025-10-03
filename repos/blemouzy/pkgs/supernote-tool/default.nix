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
  version = "0.6.2";
  format = "pyproject";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "jya-dev";
    repo = "supernote-tool";
    rev = "v${version}";
    hash = "sha256-xdfVrRbShBXdf6KCmNJfVmrTj6B520X3s9dYWURGyb8=";
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
