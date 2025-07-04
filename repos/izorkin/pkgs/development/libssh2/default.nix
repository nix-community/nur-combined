{ lib, stdenv, fetchurl, openssl, zlib, windows }:

stdenv.mkDerivation rec {
  pname = "libssh2";
  version = "1.11.1";

  src = fetchurl {
    url = "${meta.homepage}/download/${pname}-${version}.tar.gz";
    sha256 = "sha256-2ex2y+NNuY7sNTn+LImdJrDIN8s+tGalaw8QnKv2WPc=";
  };

  outputs = [ "out" "dev" "devdoc" ];

  propagatedBuildInputs = [ openssl ]; # see Libs: in libssh2.pc

  buildInputs = [ zlib ]
    ++ lib.optional stdenv.hostPlatform.isMinGW windows.mingw_w64;

  # this could be accomplished by updateAutotoolsGnuConfigScriptsHook, but that causes infinite recursion
  # necessary for FreeBSD code path in configure
  postPatch = ''
    substituteInPlace ./config.guess --replace-fail /usr/bin/uname uname
  '';

  meta = {
    description = "A client-side C library implementing the SSH2 protocol";
    homepage = "https://www.libssh2.org/";
    platforms = lib.platforms.all;
    maintainers = [ ];
  };
}
