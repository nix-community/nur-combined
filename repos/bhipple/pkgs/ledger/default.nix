{ ledger, fetchFromGitHub, boost16x, python3 }:

# WIP: This does not yet build.
(ledger.override { boost = boost16x; /* python = python3; */ }).overrideAttrs(o: {
  version = "2020-03-02";

  src = fetchFromGitHub {
    owner  = "ledger";
    repo   = "ledger";
    rev    = "7c09f45f501a8ae6573d62e833c4ddfe4ab8b3aa";
    sha256 = "0zw38davci9583lfhg5dpgq9rgf5fwxlhqkgbkvriix1v4sdr9ff";
  };
})
