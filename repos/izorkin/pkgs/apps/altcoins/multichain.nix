{ stdenv, fetchFromGitHub
, pkgconfig, autoreconfHook
, openssl, db48, boost163, zlib
, glib, protobuf, utillinux, libevent }:

with stdenv.lib;
stdenv.mkDerivation rec {

  name = "multichain-${version}";
  version = "2018-06-13";

  src = fetchFromGitHub {
    owner = "MultiChain";
    repo = "multichain";
    rev = "d9a0fb1ecfa445f27e8eebfdabebda754d9c597a";
    sha256 = "0is81f3z27v0wxiskf1ssmvb1xg2ykwq7g5bqhqak2c7plnhaasf";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook ];
  buildInputs = [ openssl db48 boost163 zlib
                  glib protobuf utillinux libevent ];

  configureFlags = [ "--with-boost-libdir=${boost163.out}/lib"
                     "--with-gui=no" ];

  meta = {
    description = "Open platform for blockchain applications";
    homepage = https://http://www.multichain.com/;
    platforms = platforms.linux;
  };
}
