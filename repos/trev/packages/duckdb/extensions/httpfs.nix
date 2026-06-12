{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  rev = "52afb4204a3238d6ee132e83340f8d68c40ee91c";
  hash = "sha256-LvIsma4c63KJqwgEHUAO20AGmFGMSGIzPT/dVGgSa2U=";
}
