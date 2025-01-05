{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  lua5_3,
  zlib,
}:

stdenv.mkDerivation {
  pname = "tom";
  version = "2021-10-21";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = "tom";
    rev = "5d89c1bb50200f79fac9eee5f88ed4e43ccd32a8";
    hash = "sha256-dpDNZYkOzcugtPi3ZeB9xHlYas2tdsTqfnhp7KqBMYg=";
  };

  postPatch = ''
    substituteInPlace runcgi.sh \
      --replace-fail "lua53" "${lua5_3}/bin/lua" \
      --replace-fail "tom.lua" "$out/share/lua/tom.lua"
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    lua5_3
    zlib
  ];

  installPhase = ''
    install -Dm644 *.so *.lua -t $out/share/lua
    install -Dm755 *.sh -t $out/bin

    wrapProgram $out/bin/runcgi.sh \
      --set LUA_PATH "$out/share/lua/?.lua" \
      --set LUA_CPATH "$out/share/lua/?.so"
  '';

  meta = {
    description = "Gemini frontend for git repositories";
    homepage = "https://github.com/omar-polo/tom";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
