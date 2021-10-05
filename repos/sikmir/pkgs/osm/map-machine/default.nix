{ lib, fetchFromGitHub, python3Packages, portolan }:

python3Packages.buildPythonApplication rec {
  pname = "map-machine";
  version = "2021-10-05";
  disabled = python3Packages.pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = pname;
    rev = "245c316997888f26addecd6576f5bc85b4538fe4";
    hash = "sha256-fpBuYhqLZKZ6kwF6oSeMB03qcf3P+7LRhg58BC16L40=";
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
