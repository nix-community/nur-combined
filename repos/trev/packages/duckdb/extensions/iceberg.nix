{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "iceberg";
  repo = "duckdb-iceberg";
  branch = "v1.5-variegata";
  rev = "e6fe0a4b28ed13f4a1ae5c7e12bad338c6fc13c7";
  hash = "sha256-R6+q6vw7ik0H6dN0QlsZFNXExp4YMlSvuVMOgM8o12E=";
}
