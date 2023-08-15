{ lib, fetchgit, testers, rustPlatform, git}:

rustPlatform.buildRustPackage rec {
  pname = "specsheet";
  version = "8821c6f"; # Latest commit as of 08/15/2023

  src = fetchgit {
    url = "https://github.com/ogham/specsheet";
    rev = version;
    hash = "sha256-FL75awPzLWKYX87EQ2lc/nlhE3iGKo7rM2VYBcG8YqU=";
  };

  cargoSha256 = "sha256-94wC9ro0bx3mV0deCeaHz1zD0gYBPOHd56pSAb7E6Us=";

  nativeBuildInputs = [ git ];

  # Found argument '--test-threads' which wasn't expected, or isn't valid in this context
  doCheck = false;

  meta = with lib; {
    homepage = "https://specsheet.software/";
    description = "The testing toolkit";
  };
}
