{ lib, stdenv, fetchurl, openssl, zlib, windows
, hostPlatform
}:

stdenv.mkDerivation rec {
  pname = "libssh2";
  version = "1.9.0";

  src = fetchurl {
    url = "${meta.homepage}/download/${pname}-${version}.tar.gz";
    sha256 = "1zfsz9nldakfz61d2j70pk29zlmj7w2vv46s9l3x2prhcgaqpyym";
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
