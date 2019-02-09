{ stdenv, fetchFromGitHub
, pkgconfig, autoreconfHook
, openssl, db48, boost163, zlib
, glib, protobuf, utillinux, libevent }:

with stdenv.lib;
stdenv.mkDerivation rec {

  name = "omnicore-${version}";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "OmniLayer";
    repo = "omnicore";
    rev = "v${version}";
    sha256 = "1gqnhyjym4q9c74j22mc97x1pl027fxnib4r2p75my66hzch54dz";
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
