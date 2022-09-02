{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gpx-converter";
  version = "2021-11-19";

  src = fetchFromGitHub {
    owner = "nidhaloff";
    repo = "gpx-converter";
    rev = "77790e9258ce845daf640f25614cd2e51cef7eb6";
    hash = "sha256-T7CxFeWoK7lR0oL4kIQoKqirw5oLnh6+SBC5fcnaANc=";
  };

  propagatedBuildInputs = with python3Packages; [ gpxpy numpy pandas ];

  checkInputs = with python3Packages; [ pytestCheckHook pytest-runner ];

  meta = with lib; {
    description = "Python package for manipulating gpx files and easily convert gpx to other different formats";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
