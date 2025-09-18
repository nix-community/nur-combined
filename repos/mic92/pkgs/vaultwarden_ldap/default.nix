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
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "vaultwarden_ldap";
    rev = "v${version}";
    sha256 = "sha256-p0zxak1Wl2Zeq2idhad6nhM7DXSD0z4lP+BNiAIFPXw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoHash = "sha256-boe8JgDFKDf6+laow3z8yr19qx3xBA7zz9hV+IGsWaM=";

  meta = with lib; {
    description = "LDAP directory connector for vaultwarden";
    homepage = "https://github.com/ViViDboarder/vaultwarden_ldap";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
