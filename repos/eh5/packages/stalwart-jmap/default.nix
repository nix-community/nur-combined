{ lib, rustPlatform, fetchFromGitHub, llvmPackages_14 }:
let
  inherit (llvmPackages_14) clang libclang;
in
rustPlatform.buildRustPackage rec {
  pname = "stalwart-jmap";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "jmap-server";
    rev = "v${version}";
    sha256 = "sha256-rTOcong1F3+gM6Adi6pB1wvS/fiGoKHz+FyTb/edVhg=";
  };

  cargoPatches = [ ./fix-cargo-lock.patch ];
  cargoSha256 = "sha256-+f12En+pkfTlT4GZvG98q9WhSwIT3duYVbKNj3TK+CE=";

  nativeBuildInputs = [ clang ];

  LIBCLANG_PATH = "${lib.getLib libclang}/lib";

  doCheck = false;

  meta = with lib; {
    description = "Stalwart Imap server ";
    homepage = "https://stalw.art/jmap";
    license = licenses.agpl3Plus;
  };
}
