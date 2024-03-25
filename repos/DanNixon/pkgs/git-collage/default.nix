{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-collage";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-+1ro/4MGdehwg2T95UMix4hoQNNLtpvPPM2oOBasxeY=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-bJfEtxePDeqCB1vX7IM26lc0QRlubE7WDjO+EjieffE=";

  meta = {
    description = "A tool for selectively mirroring Git repositories.";
    homepage = "https://github.com/DanNixon/${pname}";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
