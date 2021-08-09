{ lib, stdenv, rustPlatform, fetchFromGitLab, pkgs }:

rustPlatform.buildRustPackage rec {
  pname = "paper";
  version = "unstable-2021-07-26";

  buildInputs = with pkgs; [ fontconfig ];
  nativeBuildInputs = with pkgs; [ pkg-config ];
  fontconfig = pkgs.fontconfig;

  src = fetchFromGitLab {
    owner = "snakedye";
    repo = pname;
    rev = "bf3594013f4805e289286980fc07a85d58a73cca";
    sha256 = "sha256-MFvDd1e5k2k86dtLOCvYD9qE6dkDgpCVDQ+x8Ksm+24=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "snui-0.1.0" = "1d2pvraj61n0a3p2xi21dq4kgf0sjiqxyhjzhqy0mcbg7f4nwhrq";
    };
  };

  cargoSha256 = lib.fakeSha256;

  meta = with lib; {
    description = "A wallpaper daemon for Wayland compositors";
    homepage = "https://github.com/snakedye/paper";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ devins2518 ];
  };
}
