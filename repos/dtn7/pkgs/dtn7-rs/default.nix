{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "dtn7-rs";
  version = "unstable-2020-04-05";

  src = fetchFromGitHub {
    owner = "dtn7";
    repo = "dtn7-rs";
    rev = "5032ad0c1b19bb4af60c806f2b5125df323ac18b";
    sha256 = "1bh9mc9sigsdrcnvdna0pzmbjcy6lx4vhzza4mw88jiqfgsmmr8d";
  };

  cargoPatches = [ ./cargo-lock.patch ]; # Cargo.lock is missing.
  cargoSha256 = "1mfdf75mi3finv3k2k235lzzybh6lrj6a48srjhaixnp20aac62j";

  meta = with lib; {
    description = "Rust implementation of DTN7";
    homepage = "https://github.com/dtn7/dtn7-rs";
    license = with licenses; [ asl20 mit ];
    maintainers = with maintainers; [ oxzi ];
  };
}
