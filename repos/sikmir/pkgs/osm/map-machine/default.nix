{ lib, fetchFromGitHub, python3Packages, portolan }:

python3Packages.buildPythonApplication rec {
  pname = "map-machine";
  version = "2021-11-19";
  disabled = python3Packages.pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = pname;
    rev = "44ad87356b806d8af9c40b2beca42de95049fba9";
    hash = "sha256-3MlWr3Wu2z7TkBCwM+wSFC0a619esi76GvDlypGnCss=";
  };

  propagatedBuildInputs = with python3Packages; [
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

  checkInputs = with python3Packages; [ pytestCheckHook ];
  preCheck = "export PATH=$PATH:$out/bin";
  disabledTests = [
    "test_tile"
  ];

  meta = with lib; {
    description = "A simple renderer for OpenStreetMap with custom icons";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
