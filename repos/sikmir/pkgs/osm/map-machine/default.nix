{
  lib,
  fetchFromGitHub,
  python3Packages,
  portolan,
}:

python3Packages.buildPythonApplication rec {
  pname = "map-machine";
  version = "0.1.9";
  pyproject = true;
  disabled = python3Packages.pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = "map-machine";
    tag = "v${version}";
    hash = "sha256-aOfvVyTgDxh7T2oAc+S1eU9b/JjXAhfc3WfR27ECXcY=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    cairosvg
    colour
    numpy
    pillow
    portolan
    pycairo
    pyyaml
    shapely
    svgwrite
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
}
