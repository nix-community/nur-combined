{
  callPackage,
  expat,
  minizip-ng,
  zlib,
}:

(callPackage ./generic.nix { }) {
  name = "excel";
  repo = "duckdb-excel";
  branch = "main";
  rev = "854b06318382f034792aa244427da7e1d1328350";
  hash = "sha256-LWCmzyPgG4vmFpKEqHtmfihBBTxgFmkj4oBUkiwzhHI=";
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
