{ stdenv
, fetchFromGitHub
, rustPlatform
, pkgconfig
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
  cargoSha256 = "01pyqpi5sw5c1yixl74h5kpiynzmf8jbkrf61kh9iz8049d84cpv";

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ openssl ];

  meta = with stdenv.lib; {
    description = "ACME (RFC 8555) client daemon";
    homepage = "https://github.com/breard-r/acmed";
    license = licenses.mit;
    maintainers = with maintainers; [ _0x4A6F ];
    platforms = platforms.linux;
  };
}
