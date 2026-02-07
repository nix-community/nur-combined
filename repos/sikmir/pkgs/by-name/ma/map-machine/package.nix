{
  lib,
  fetchFromGitHub,
  python3Packages,
  portolan,
  roentgen-icons,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "map-machine";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "enzet";
    repo = "map-machine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OLwW+mZ+zYhPV7w7qAWsAOt2q7FhpYYoY5Kz6KQuGfg=";
  };

  build-system = with python3Packages; [ setuptools ];

  pythonRelaxDeps = true;

  dependencies = with python3Packages; [
    cairosvg
    colour
    gpxpy
    numpy
    pillow
    portolan
    pycairo
    pyyaml
    roentgen-icons
    shapely
    svgwrite
    typing-extensions
    urllib3
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  preCheck = "export PATH=$PATH:$out/bin";
  disabledTests = [ "test_tile" ];

  meta = {
    description = "A simple renderer for OpenStreetMap with custom icons";
    homepage = "https://github.com/enzet/map-machine";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "map-machine";
  };
})
