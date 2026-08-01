{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "7a76d2a43faee43e71cec8ef2576474cc56282a4";
  hash = "sha256-GR9CmY+fka+TRMQzoK6aDuNZZEkQ3vC29cX43Lw8aO0=";
}
