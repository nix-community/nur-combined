{ lib, fetchFromGitHub, python3Packages, s2sphere }:

python3Packages.buildPythonApplication rec {
  pname = "py-staticmaps";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "flopp";
    repo = "py-staticmaps";
    rev = "v${version}";
    hash = "sha256-vW457HbdDDhfz8hsvEN3/HJmIHKdrRDVNuhSpZXoZ78=";
  };

  propagatedBuildInputs = with python3Packages; [ appdirs geographiclib pillow pycairo python-slugify requests s2sphere svgwrite ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "A python module to create static map images with markers, geodesic lines, etc";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
