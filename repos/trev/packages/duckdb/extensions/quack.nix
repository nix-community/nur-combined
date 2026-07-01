{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "quack";
  repo = "duckdb-quack";
  branch = "v1.5-variegata";
  rev = "29fc0391dc14bc69914aaad0493a1d31bc67e07f";
  hash = "sha256-0HJwOxcuQXbFnDAFj6+NvpOfj8hdi/S8fmDERBnlesk=";
}
