{ lib
, fetchFromGitHub
, pkgs
, fenix
}:

let
#  fenix = import
#    (fetchTarball {
#      url = "https://github.com/nix-community/fenix/archive/main.tar.gz";
#      sha256 = "sha256:1l0j43iks97lk70s3zb43vfbbjf1j1x2nrpbfx559xfv0ivn45br";
#    })
#    { system = "x86_64-linux"; };
  ## WARNING: ONLY FLAKE USER COULD USE THIS DERIVATION DIRECTLY
  rustPlatform = pkgs.makeRustPlatform { inherit (fenix.minimal) cargo rustc; };
in
rustPlatform.buildRustPackage rec{
  pname = "tuic";
  version = "0.8.5";

  src = fetchFromGitHub {
    rev = "0303155b28a24cd0fa2e9efa8832dd914fe74a5a";
    owner = "EAimTY";
    repo = pname;
    sha256 = "sha256-YML4oMJfJoRzN19KJRYA5dzHEpTYmpai59R7h3O3Kd0=";
  };
  cargoPatches = [
    # a patch file to add/update Cargo.lock in the source code
    ./add-Cargo.lock.patch
  ];
  cargoSha256 = "sha256-/qossKARuoeTuOLgcFc5+TrZ4d8yPC/mUiDrpvqXA+M=";

  meta = with lib; {
    homepage = "https://github.com/EAimTY/tuic";
    description = ''
      Delicately-TUICed high-performance proxy built on top of the QUIC protocol
    '';
    #    maintainers = with maintainers; [ oluceps ];
  };
}
