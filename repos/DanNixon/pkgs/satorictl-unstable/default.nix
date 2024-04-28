{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "satorictl-unstable";
  version = "2024-03-13";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "satori";
    rev = "342afa4635dbc577a1ef7ce6c05bbef1bcc65202";
    hash = "sha256-O8ZdF86GtQhbugLqfbA5i5DcL+Twp0vg0vC1i/wpv0s=";
  };

  cargoHash = "sha256-VYMUHR/NJbfx+wfkl6qUkRTyeVjjz/9f2IWgDISEtl8=";

  buildAndTestSubdir = "ctl";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = {
    description = "CLI control tool for Satori, a very simple NVR for IP cameras.";
    homepage = "https://github.com/DanNixon/satori";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
