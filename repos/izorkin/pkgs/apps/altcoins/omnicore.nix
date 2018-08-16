{ stdenv, fetchFromGitHub
, pkgconfig, autoreconfHook
, openssl, db48, boost163, zlib
, glib, protobuf, utillinux, libevent }:

with stdenv.lib;
stdenv.mkDerivation rec {

  name = "omnicore-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "OmniLayer";
    repo = "omnicore";
    rev = "v${version}";
    sha256 = "07iv0h7g4b514rab2fnwz5ppdd1xvp58c7qqhnw20dihhz6qxypa";
  };

  nativeBuildInputs = [ pkgconfig autoreconfHook ];
  buildInputs = [ openssl db48 boost163 zlib
                  glib protobuf utillinux libevent ];

  configureFlags = [ "--with-boost-libdir=${boost163.out}/lib"
                     "--with-gui=no" ];

  meta = {
    description = "Open-source, fully-decentralized asset platform on the Bitcoin Blockchain";
    homepage = https://www.omnilayer.org/;
    platforms = platforms.linux;
  };
}
