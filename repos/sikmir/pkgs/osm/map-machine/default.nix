{ lib, fetchFromGitHub, python3Packages, portolan }:

python3Packages.buildPythonApplication rec {
  pname = "map-machine";
  version = "2021-09-28";
  disabled = python3Packages.pythonOlder "3.9";

  src = fetchFromGitHub {
    owner = "enzet";
    repo = pname;
    rev = "eacb6c8ee1bb2f1f22591593e54711733c8f943a";
    hash = "sha256-FFqphxNVIfR6RBiXa7/uMKWrVuZQcc9MrzQy4RWE814=";
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
    platforms = platforms.unix;
  };
}
