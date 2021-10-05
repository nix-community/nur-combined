{ lib, stdenv, fetchFromGitHub, pkg-config, makeWrapper
, lua5_3, memstreamHook, zlib
}:

stdenv.mkDerivation rec {
  pname = "tom";
  version = "2021-09-24";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = "87f805afd12ea0e971c6bc8278d94aa85120da6d";
    hash = "sha256-Syz73/h9z6ZLDywhfQzh2NKC0nWFWon3SK0KHptK5Cc=";
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
