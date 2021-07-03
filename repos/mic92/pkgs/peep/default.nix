{ lib, fetchFromGitHub, rustPlatform, fetchpatch }:
rustPlatform.buildRustPackage rec {
  pname = "peep-unstable";
  version = "2021-04-17";

  src = fetchFromGitHub {
    owner = "ryochack";
    repo = "peep";
    rev = "0eceafe16ff1f9c6d6784cca75b6f612c38901c4";
    sha256 = "sha256-HtyT9kFS7derPhiBzICHIz3AvYVcYpUj1OW+t5RivRs=";
  };

  cargoSha256 = "sha256-b063UdrOrWzrplScBCqQhqZv3FJ9W/LCZ75RnhPM6fM=";

  meta = with lib; {
    description = "The CLI text viewer tool that works like less command on small pane within the terminal window.";
    inherit (src.meta) homepage;
    license = licenses.mit;
  };
}
