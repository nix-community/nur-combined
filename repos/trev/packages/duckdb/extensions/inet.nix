{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "inet";
  repo = "duckdb-inet";
  rev = "fe7f60bb60245197680fb07ecd1629a1dc3d91c8";
  hash = "sha256-8YeYuowhFz4XctNiAU7SG+QjnuQ416erAPjKpexk7Rw=";
  loadOptions = [ "INCLUDE_DIR src/include" ];
}
