{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, darwin
}:
let
  inherit (darwin.apple_sdk.frameworks) Security CoreServices;
in
rustPlatform.buildRustPackage rec {
  pname = "vaultwarden_ldap";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "vaultwarden_ldap";
    rev = "v${version}";
    sha256 = "sha256-sdiK5ly9tylvJ7ITaTkdzLtNT29nIJPZfVWC/Jgp2a4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoSha256 = "sha256-lz8nRzdMezdiYYDRBMiGYXMvJ0XRRbsQ06kxDWbzZwY=";

  meta = with lib; {
    description = "LDAP directory connector for vaultwarden";
    homepage = "https://github.com/ViViDboarder/vaultwarden_ldap";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
