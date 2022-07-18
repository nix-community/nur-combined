{ lib, stdenv, fetchurl, openssl, zlib, windows }:

stdenv.mkDerivation rec {
  pname = "libssh2";
  version = "1.10.0";

  src = fetchurl {
    url = "${meta.homepage}/download/${pname}-${version}.tar.gz";
    sha256 = "0l8xwhhscvss7q007vpbkbv7jh9s43579rx2sf8lnfgd7l7yjr1d";
  };

  outputs = [ "out" "dev" "devdoc" ];

  patches = [
    # https://github.com/libssh2/libssh2/pull/700
    # openssl: add support for LibreSSL 3.5.x
    ./patch/openssl_add_support_for_libressl_3_5.patch
  ];

  buildInputs = [ openssl zlib ]
    ++ lib.optional stdenv.hostPlatform.isMinGW windows.mingw_w64;

  meta = with lib; {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = "https://www.libssh2.org/";
    platforms = platforms.all;
    maintainers = [ ];
  };
}
