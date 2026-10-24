{
  callPackage,
  expat,
  minizip-ng,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "excel";
  repo = "duckdb-excel";
  rev = "81bb84b115b97cc4edec4827714cac80da0127e1";
  hash = "sha256-6Z5MLv9aT09KMSwvgsTWsWpst1nmBZ90xEHX/r98ZEk=";
  loadOptions = [
    "SOURCE_DIR \${PROJECT_SOURCE_DIR}/extension_external/excel"
    "INCLUDE_DIR \${PROJECT_SOURCE_DIR}/extension_external/excel/src/excel/include"
  ];
  duckdbBuildInputs = [
    expat
    minizip-ng
    zlib
  ];
}
