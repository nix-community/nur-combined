{
  lib,
  fetchFromGitHub,
  python3Packages,
  sqlite,
}:

python3Packages.buildPythonApplication {
  pname = "polytiles";
  version = "0-unstable-2017-06-09";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Zverik";
    repo = "polytiles";
    rev = "c0a057594de9041c7b3ac234a3590101e3825f2d";
    hash = "sha256-7rsMx8sQgl8cRiUncP3/mPne6ARj3K2FICU+frUeEUs=";
  };

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    psycopg2
    python-mapnik
    shapely
    sqlite
  ];

  meta = {
    description = "A script to render tiles for an area with mapnik";
    homepage = "https://github.com/Zverik/polytiles";
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.sikmir ];
    broken = true; # python-mapnik
  };
}
