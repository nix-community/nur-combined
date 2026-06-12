{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "excel";
  repo = "duckdb-excel";
  rev = "f4c72b5ef04a03b3a78a95b5a2ee94ba93e3178d";
  hash = "sha256-hyHTiTfRR+hXJ7hZKt/h/Hu1zNgEYEbMozIv6WZbnfA=";
  loadOptions = [ "INCLUDE_DIR src/excel/include" ];
}
