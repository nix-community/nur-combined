{ stdenv, fetchurl, openssl, zlib, windows
, hostPlatform
}:

stdenv.mkDerivation rec {
  pname = "libssh2";
  version = "1.8.2";

  src = fetchurl {
    url = "${meta.homepage}/download/${pname}-${version}.tar.gz";
    sha256 = "0rqd37pc80nm2pz4sa2m9pfc48axys7jwq1l7z0vii5nyvchg0q8";
  };

  outputs = [ "out" "dev" "devdoc" ];

  buildInputs = [ openssl zlib ]
    ++ stdenv.lib.optional hostPlatform.isMinGW windows.mingw_w64;

  meta = {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = https://www.libssh2.org;
    platforms = stdenv.lib.platforms.all;
    maintainers = [ ];
  };
}
