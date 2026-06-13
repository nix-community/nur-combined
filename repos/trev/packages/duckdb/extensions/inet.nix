{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "inet";
  repo = "duckdb-inet";
  rev = "bf675673d9ed8c08522863db4e40ccaa18c797e0";
  hash = "sha256-yGNlgeedX2oBpL6I93okqCauKp1qQTQXeq/Fn5tz0vc=";
  loadOptions = [ "INCLUDE_DIR src/include" ];
}
