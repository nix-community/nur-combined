{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "gpx-cmd-tools";
  version = "0-unstable-2020-08-08";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tkrajina";
    repo = "gpx-cmd-tools";
    rev = "e042c4d65cc153ddf3589b4d8723bed5f71a9d0d";
    hash = "sha256-x3/PNACBrT5XSlgpZj0WO27KW0DiF6Je2z3gX5g/Gz0=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [ gpxpy ];

  meta = {
    description = "Set of GPX command-line utilities";
    homepage = "https://github.com/tkrajina/gpx-cmd-tools";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
