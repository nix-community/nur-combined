{ lib, fetchFromGitHub, python3Packages, portolan }:

python3Packages.buildPythonApplication rec {
  pname = "map-machine";
  version = "2022-02-24";
  disabled = python3Packages.pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = pname;
    rev = "1f4fb66c85720476b7a30138b0da51a10d6a48e8";
    hash = "sha256-MGBI9teUeJ8BZl47vvFFvbS/FzNyFiTIkOtKoXiA1AI=";
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
