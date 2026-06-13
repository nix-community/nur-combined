{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "odbc_scanner";
  repo = "odbc-scanner";
  rev = "274a3307341dcafd62471c09b45c5d858d6c95cc";
  hash = "sha256-I3LtOipBN+WuYiuWvt9sptc7mVglutxo/lMQCvsoz8o=";
  loadOptions = [ "DONT_LINK" ];
}
