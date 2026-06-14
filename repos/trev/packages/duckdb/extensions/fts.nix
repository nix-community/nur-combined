{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "fts";
  repo = "duckdb-fts";
  branch = "main";
  rev = "50ba657efa1fb8e3daf7eab95eb1896db6d64efb";
  hash = "sha256-Uv5QlCxaZk5e/6u7awr00G6zGO1Vo+l2YlcXGEk35fU=";
  loadOptions = [ "DONT_LINK" ];
}
