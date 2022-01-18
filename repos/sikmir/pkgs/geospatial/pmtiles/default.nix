{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "pmtiles";
  version = "2021-12-29";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "PMTiles";
    rev = "fb4aa544d98654b575c2d694ddaeb9384b2a3f77";
    hash = "sha256-AWaKlJGjqMM3mRx2q2YD6X5DHYEoV9RCuszh36QdXX0=";
  };

  sourceRoot = "${src.name}/python";

  meta = with lib; {
    description = "Library and utilities to write and read PMTiles files - cloud-optimized archives of map tiles";
    inherit (src.meta) homepage;
    license = licenses.bsd3;
    maintainers = [ maintainers.sikmir ];
  };
}
