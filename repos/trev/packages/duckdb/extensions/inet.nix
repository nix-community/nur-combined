{
  callPackage,
  lib,
}:

(callPackage ./generic.nix { }) {
  name = "inet";
  repo = "duckdb-inet";
  branch = "main";
  rev = "bf675673d9ed8c08522863db4e40ccaa18c797e0";
  hash = "sha256-Qj1kVNv2M3Od7o537yDQE6aae0xUhCReGZQaM+c5fU8=";
  fetchSubmodules = true;
  loadOptions = [ "DONT_LINK" ];
}
