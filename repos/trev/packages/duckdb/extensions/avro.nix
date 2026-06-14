{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "avro";
  repo = "duckdb-avro";
  branch = "v1.5-variegata";
  rev = "0e499606ab97f96f83d017c1720f1149d510b337";
  hash = "sha256-HniFvjRnRnqJ34Vxh8I4pu4y4KZEzpMaHCfFZsntyCw=";
}
