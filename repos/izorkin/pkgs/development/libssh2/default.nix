{ lib, stdenv, fetchurl, openssl, zlib, windows
, hostPlatform
}:

stdenv.mkDerivation rec {
  pname = "libssh2";
  version = "1.10.0";

  src = fetchurl {
    url = "${meta.homepage}/download/${pname}-${version}.tar.gz";
    sha256 = "0l8xwhhscvss7q007vpbkbv7jh9s43579rx2sf8lnfgd7l7yjr1d";
  };

  outputs = [ "out" "dev" "devdoc" ];

  buildInputs = [ openssl zlib ]
    ++ lib.optional hostPlatform.isMinGW windows.mingw_w64;

  meta = with lib; {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = "https://www.libssh2.org/";
    platforms = platforms.all;
    maintainers = [ ];
  };
}
