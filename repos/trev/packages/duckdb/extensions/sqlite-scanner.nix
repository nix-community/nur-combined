{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "44f5dde2e840c9316b4bfb293c46d886c2df9ff2";
  hash = "sha256-SewBGN9BpnxoH+eDpxx42nZn4ICXvdeI/TqSQjHGjBE=";
}
