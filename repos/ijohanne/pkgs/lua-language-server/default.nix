{ stdenv
, fetchFromGitHub
, pkgconfig
, makeWrapper
, lua52Packages
, ncurses
, ninja
, readline
, zlib
, lib
, sources
}:
with lib;
stdenv.mkDerivation rec {
  pname = "lua-language-server";
  version = "master";

  src = fetchFromGitHub {
    inherit (sources.lua-language-server) owner repo rev;
    sha256 = "122dw737gd0fsv906ijyywc30qi2ccrhsikhg0nrp778yjmj32zc";
    fetchSubmodules = true;
  };

  buildPhase = ''
    cd 3rd/luamake

  ''
  + optionalString
    (stdenv.isLinux)
    "ninja -f ninja/linux.ninja"
  + optionalString
    (stdenv.isDarwin)
    "ninja -f ninja/linux.ninja"
  +
  ''

    cd ../..
    ./3rd/luamake/luamake rebuild
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/Linux/lua-language-server $out/bin
  '';

  nativeBuildInputs = [
    pkgconfig
    makeWrapper
    ninja
  ];

  buildInputs = [
    lua52Packages.lua
    ncurses
    readline
    zlib
  ];

  meta = with lib; {
    description = "Lua language server";
    homepage = "https://github.com/sumneko/lua-language-server";
    platforms = with platforms; linux ++ darwin;
  };
}
