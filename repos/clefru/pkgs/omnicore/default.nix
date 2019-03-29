{ stdenv, fetchFromGitHub, pkgconfig, autoreconfHook, openssl, db48, boost162
, zlib, miniupnpc, qt4, utillinux, protobuf, qrencode, libevent
, withGui }:

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "omnicore" + (toString (optional (!withGui) "d")) + "-" + version;
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "OmniLayer";
    repo = "omnicore";
    rev = "v${version}";
    sha256 = "024n77bkkg2qmsazm14600kw4dzc3s3viv0g87ag06v1q32vq12f";
  };
  buildInputs = [ pkgconfig autoreconfHook openssl db48 boost162 zlib
                  miniupnpc protobuf libevent]
                  ++ optionals stdenv.isLinux [ utillinux ]
                  ++ optionals withGui [ qt4 qrencode ];

  configureFlags = [ "--with-boost-libdir=${boost162.out}/lib" ]
                     ++ optionals withGui [ "--with-gui=qt4" ];

  meta = {
    description = "Omni Core is a fast, portable Omni Layer implementation that is based off the Bitcoin Core codebase";
    homepage = "https://github.com/OmniLayer/omnicore";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
