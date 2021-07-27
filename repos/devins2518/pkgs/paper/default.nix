{ lib, stdenv, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "paper";
  version = "unstable-2021-07-26";

  src = fetchFromGitHub {
    owner = "snakedye";
    repo = pname;
    rev = "fc970583d56590fd149b652f12650239fb1d9856";
    sha256 = "sha256-WQDcg8eFoWASCg3S7f/egPbfdZWswFKMUsybXc0IW04=";
  };

  cargoSha256 = "sha256-EzUQcxZOc/sUhyuCZeoNFtUC54XMMeAp+FWJtvckbfM=";

  meta = with lib; {
    description = "A wallpaper daemon for Wayland compositors";
    homepage = "https://github.com/snakedye/paper";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
