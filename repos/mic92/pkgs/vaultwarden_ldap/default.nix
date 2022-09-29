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
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "vaultwarden_ldap";
    rev = "v${version}";
    sha256 = "sha256-LXblc427x4txZmPa94W6RDOsHXofV/AU4v/bLXXZbTw=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security CoreServices ];

  cargoSha256 = "sha256-T8M4EdFpVsj8XHfY+47QfgMkX1+tZgvWBZqHG65uj24=";

  meta = with lib; {
    description = "LDAP directory connector for vaultwarden";
    homepage = "https://github.com/ViViDboarder/vaultwarden_ldap";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
