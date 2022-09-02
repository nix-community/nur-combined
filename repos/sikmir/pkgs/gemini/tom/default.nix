{ lib, stdenv, fetchFromGitHub, pkg-config, makeWrapper
, lua5_3, memstreamHook, zlib
}:

stdenv.mkDerivation rec {
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
      --replace "lua53" "${lua5_3}/bin/lua" \
      --replace "tom.lua" "$out/share/lua/tom.lua"
  '';

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [ lua5_3 zlib ] ++ lib.optional stdenv.isDarwin memstreamHook;

  installPhase = ''
    install -Dm644 *.so *.lua -t $out/share/lua
    install -Dm755 *.sh -t $out/bin

    wrapProgram $out/bin/runcgi.sh \
      --set LUA_PATH "$out/share/lua/?.lua" \
      --set LUA_CPATH "$out/share/lua/?.so"
  '';

  meta = with lib; {
    description = "Gemini frontend for git repositories";
    inherit (src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
