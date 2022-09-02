{ lib, fetchFromGitHub, python3Packages, sqlite }:

python3Packages.buildPythonApplication rec {
  pname = "polytiles";
  version = "2017-06-09";

  src = fetchFromGitHub {
    owner = "Zverik";
    repo = "polytiles";
    rev = "c0a057594de9041c7b3ac234a3590101e3825f2d";
    hash = "sha256-7rsMx8sQgl8cRiUncP3/mPne6ARj3K2FICU+frUeEUs=";
  };

  propagatedBuildInputs = with python3Packages; [
    psycopg2
    python-mapnik
    shapely
    sqlite
  ];

  meta = with lib; {
    description = "A script to render tiles for an area with mapnik";
    inherit (src.meta) homepage;
    license = licenses.wtfpl;
    maintainers = [ maintainers.sikmir ];
  };
}
