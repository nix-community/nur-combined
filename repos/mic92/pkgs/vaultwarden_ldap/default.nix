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
  pname = "vaultwarden_ldap";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "vaultwarden_ldap";
    rev = "v${version}";
    sha256 = "sha256-dLM24NioLrFPJ94nA76HzYskE3Wy7DNnFw6LVAPsqlc=";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoSha256 = "sha256-hjUk465+OqLJ5D0PLNf1w4dSrTnXXbzH85fGX2Oqh+U=";

  meta = with lib; {
    description = "LDAP directory connector for vaultwarden";
    homepage = "https://github.com/ViViDboarder/vaultwarden_ldap";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
