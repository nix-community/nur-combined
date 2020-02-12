{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  name = "dtn7-rs-${version}";
  version = "unstable-2020-01-28";

  src = fetchFromGitHub {
    owner = "dtn7";
    repo = "dtn7-rs";
    rev = "47c48742d48539d633dd072a7b24bdaae81c55a1";
    sha256 = "17ssf37qc6bf1y1zfcy02cl96z0js5i1j3kzdadf5yfwivz1nnbq";
  };

  cargoPatches = [ ./cargo-lock.patch ]; # Cargo.lock is missing.
  cargoSha256 = "17ya3rivkyi21lw5lq8cv9p4mls935gpisqvbzpb9nlmg3h4jjll";

  doCheck = false; # Skip failing tests.

  meta = with lib; {
    description = "Rust implementation of DTN7";
    homepage = "https://github.com/dtn7/dtn7-rs";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ geistesk ];
  };
}
