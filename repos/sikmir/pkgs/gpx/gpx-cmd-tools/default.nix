{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "gpx-cmd-tools";
  version = "2020-08-08";

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "gpx-cmd-tools";
    rev = "e042c4d65cc153ddf3589b4d8723bed5f71a9d0d";
    hash = "sha256-x3/PNACBrT5XSlgpZj0WO27KW0DiF6Je2z3gX5g/Gz0=";
  };

  propagatedBuildInputs = with python3Packages; [ gpxpy ];

  meta = with lib; {
    description = "Set of GPX command-line utilities";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
