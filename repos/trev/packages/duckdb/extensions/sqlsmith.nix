{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlsmith";
  repo = "duckdb-sqlsmith";
  branch = "main";
  rev = "8822e3f70a49681f12b5fde8f89d461ce11ef482";
  hash = "sha256-IXJ807Ol14XgsGSgsFlQfQRi37QB0S8pqO5ZRoNBPSk=";
  loadOptions = [ "DONT_LINK" ];
}
