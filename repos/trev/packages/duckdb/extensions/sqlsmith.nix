{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "sqlsmith";
  repo = "duckdb-sqlsmith";
  rev = "e47106c6fef6e019feaf8cedfc2ef737428a386c";
  hash = "sha256-yeIiKrnmqB9ogmkSu+h151zD35r4NnolMEhTP6deYSo=";
  loadOptions = [ "DONT_LINK" ];
}
