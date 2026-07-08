{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlite_scanner";
  repo = "duckdb-sqlite";
  branch = "v1.5-variegata";
  rev = "142ba7f01f5c2b30a962a5d814602bf1ad5766a5";
  hash = "sha256-+Dg6ZPZ+puSMdBqLeYLMyzETm40BPeZL/MMlj4+OXlM=";
}
