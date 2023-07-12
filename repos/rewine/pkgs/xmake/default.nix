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
  version = "2.8.1";

  src = fetchurl {
    url = "https://github.com/xmake-io/xmake/releases/download/v${version}/xmake-v${version}.tar.gz";
    hash = "sha256-nM0LV3CVaLNbB1EKjc+Ywir2aQ/xWgET2Cu+kh908l8=";
  };

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

  meta = with lib; {
    description = "A cross-platform build utility based on Lua";
    homepage    = "https://xmake.io";
    license     = licenses.asl20;
    platforms   = platforms.all;
    maintainers = with maintainers; [ rewine ];
  };
}
