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
    rev = "c0738a96b587c80a73f93cb653c032e1cc95b6f4";
    sha256 = "0kdn0i59i444k5v5xfh6452s52bvkqfl0qi24nrzdwnivlgs8k4b";
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
