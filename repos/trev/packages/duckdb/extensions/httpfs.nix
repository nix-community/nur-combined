{ callPackage, curl }:

(callPackage ./generic.nix { }) {
  name = "httpfs";
  repo = "duckdb-httpfs";
  branch = "main";
  rev = "1c3cc07aaf6c612547341a63ca19d584eb8497b4";
  hash = "sha256-MDRpvRVxFrATiNKKxXCd3fan8bnYukmMvS+gt1q1osQ=";
  duckdbBuildInputs = [
    curl
  ];
}
