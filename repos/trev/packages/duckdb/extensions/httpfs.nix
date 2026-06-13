{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  rev = "c3f215ab360f04dc3d3d5305fa81849c0121f111";
  hash = "sha256-Yo/f+9aDU3qZw1aGv0ABXjl40QoeUhGIXe2dlN91PHs=";
}
