{ lib
, stdenv
, fetchurl
, pkg-config
, luaPackages
, readline
, ncurses
, lz4
, tbox
, xmake-core-sv
}:

stdenv.mkDerivation rec {
  pname = "xmake";
  version = "2.7.9";

  src = fetchurl {
    url = "https://github.com/xmake-io/xmake/releases/download/v${version}/xmake-v${version}.tar.gz";
    hash = "sha256-m0LYY0gz9IhbBbiUKd1gBE3KmSMvYJYyC42Ff7M9Ku8=";
  };

  enableParallelBuilding = true;

  #patches = [
  #  ./0001-use-external.diff
  #];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    luaPackages.lua
    luaPackages.cjson
    readline
    ncurses
    lz4
    tbox
    xmake-core-sv
  ];

  configureFlags = [ "--external=y" ];

  #installFlags = [ "prefix=${placeholder "out"}" ];

  #env.NIX_CFLAGS_COMPILE = toString [
  #  "-L${tbox}/lib"
  #];

  meta = with lib; {
    description = "A cross-platform build utility based on Lua";
    homepage    = "https://xmake.io";
    license     = licenses.asl20;
    platforms   = platforms.all;
    maintainers = with maintainers; [ rewine ];
  };
}
