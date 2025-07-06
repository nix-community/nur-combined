{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pmtiles";
  version = "3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "PMTiles";
    rev = "4bd801305cf264463ff96726a71bec8619c8af2b";
    hash = "sha256-VKI09aEdZdGJosDBe9PGQEDdIaDk8xq6EToiUc1XmOQ=";
  };

  sourceRoot = "${src.name}/python";

  build-system = with python3Packages; [ setuptools ];

  meta = {
    description = "Library and utilities to write and read PMTiles files - cloud-optimized archives of map tiles";
    homepage = "https://github.com/protomaps/PMTiles";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
