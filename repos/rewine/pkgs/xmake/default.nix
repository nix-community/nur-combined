{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, luaPackages
, readline
, lz4
, tbox
, xmake-core-sv
}:

stdenv.mkDerivation rec {
  pname = "xmake";
  version = "2.7.9";

  src = fetchFromGitHub {
    owner = "xmake-io";
    repo = "xmake";
    rev = "v${version}";
    hash = "sha256-g0hB2X/+/SDJQ9n5AdVGlRCk+FBoEI3+UepruOoNBV0=";
  };

  #enableParallelBuilding = true;

  patches = [
    ./0001-use-external.diff
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    luaPackages.lua
    luaPackages.cjson
    readline
    lz4
    tbox
    xmake-core-sv
  ];

  configureFlags = [ "--external=true" ];

  #installFlags = [ "prefix=${placeholder "out"}" ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-L${tbox}/lib"
  ];

  meta = with lib; {
    description = "A cross-platform build utility based on Lua";
    homepage    = "https://xmake.io";
    license     = licenses.asl20;
    platforms   = platforms.all;
    maintainers = with maintainers; [ rewine ];
  };
}
