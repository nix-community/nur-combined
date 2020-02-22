{ stdenv
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
  buildInputs = [ openssl ] ++ stdenv.lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoSha256 = "16fh38bhkiv97dik2984nlxks5j91g943gw84i6q32grccdlk78p";

  meta = with stdenv.lib; {
    description = "LDAP directory connector for bitwarden_rs";
    homepage = https://github.com/ViViDboarder/bitwarden_rs_ldap;
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
