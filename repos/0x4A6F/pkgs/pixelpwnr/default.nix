{ lib
, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "pixelpwnr";
  version = "unstable-2020-02-05";

  src = fetchFromGitHub {
    owner = "timvisee";
    repo = "pixelpwnr";
    rev = "fd8f35639dfaefef83ccb752bdc20434d208f0a6";
    sha256 = "17sks803g3pm13f9xy4zj0p14kwlhx9v0blmrg07ixj73xbvabrw";
  };

  cargoSha256 = "sha256-T/Qce/K67bM2XRBp8wFYLE05ujwi5D+ZLiOXTp2sTpM=";

  cargoPatches = [
    ./Cargo.lock.patch
    ./src.patch
  ];

  meta = with lib; {
    description = "An RPKI Validator written in Rust";
    homepage = "https://github.com/NLnetLabs/routinator";
    license = licenses.bsd3;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
