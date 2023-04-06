{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, fetchpatch
, pkg-config
, openssl
, darwin
}:
let
  inherit (darwin.apple_sdk.frameworks) Security CoreServices;
in
rustPlatform.buildRustPackage rec {
  pname = "vaultwarden_ldap";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "vaultwarden_ldap";
    rev = "v${version}";
    sha256 = "sha256-JkH4Ekd/exd/cCN25SdMfl6kAAXfqqlIPmiGepT2TUM=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoSha256 = "sha256-6jQbKks+4mT9PnUCXoYOCqjKDwmJ/PlqUzX/IQJtL4I=";

  meta = with lib; {
    description = "LDAP directory connector for vaultwarden";
    homepage = "https://github.com/ViViDboarder/vaultwarden_ldap";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
