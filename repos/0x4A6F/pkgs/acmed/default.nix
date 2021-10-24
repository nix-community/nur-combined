{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, openssl
}:

rustPlatform.buildRustPackage rec {
  pname = "acmed";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "breard-r";
    repo = pname;
    rev = "v${version}";
    sha256 = "18x2bhdsa9nggh419bg60908yxz2ia0anv4x775mah9cf2lzrwqb";
  };

  cargoPatches = [ ./Cargo.lock.patch ];
  cargoSha256 = "1xl0jgwgmv437c4impzlc49gl2ajh8h85r76r6pavm5cp8a8cn2d";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "ACME (RFC 8555) client daemon";
    homepage = "https://github.com/breard-r/acmed";
    license = licenses.mit;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
