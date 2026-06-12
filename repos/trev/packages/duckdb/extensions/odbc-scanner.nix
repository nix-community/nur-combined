{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "odbc_scanner";
  repo = "odbc-scanner";
  rev = "8a3266017af8a9abf14a49e2fd5df83d64eb5520";
  hash = "sha256-4P4Atpb2AkNAqUNxddjVvlp6PSEwORTJE/4jW/YeEuE=";
  loadOptions = [ "DONT_LINK" ];
}
