{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "excel";
  repo = "duckdb-excel";
  branch = "main";
  rev = "854b06318382f034792aa244427da7e1d1328350";
  hash = "sha256-LWCmzyPgG4vmFpKEqHtmfihBBTxgFmkj4oBUkiwzhHI=";
  loadOptions = [ "INCLUDE_DIR src/excel/include" ];
}
