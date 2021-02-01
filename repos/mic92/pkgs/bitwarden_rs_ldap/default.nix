{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, fetchpatch
, pkgconfig
, openssl
, darwin
}:
let
  inherit (darwin.apple_sdk.frameworks) Security CoreServices;
in
rustPlatform.buildRustPackage rec {
  pname = "bitwarden_rs_ldap";
  version = "0.1.1-cargo-fix";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "bitwarden_rs_ldap";
    rev = "v${version}";
    sha256 = "0a7r38as1w3gsb2fgqv58xa1v4il4kq76zvh2s3zd7ahwvrxc7zc";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoSha256 = "12vg972fxvdi2dbad7g00vccmcqhnyjl8ch2sypl1hfk83mrwgrb";

  meta = with lib; {
    description = "LDAP directory connector for bitwarden_rs";
    homepage = https://github.com/ViViDboarder/bitwarden_rs_ldap;
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
