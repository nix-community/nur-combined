{ stdenv, luaPackages, fetchFromGitHub, makeWrapper }:

let
  inherit (luaPackages) lua buildLuaPackage;
in buildLuaPackage {
  name = "fennel";
  src = fetchFromGitHub {
    owner = "bakpakin";
    repo = "fennel";
    rev = "f2a3d3b91904ef9b3f154cc493fe8b56099a9fd8";
    sha256 = "1dkclsa9m1j47cqlrj0gfkm4n64fl30dynkn6w1a7gmsfxrxhp0b";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dp fennel.lua $out/lib/lua/${lua.luaversion}/fennel.lua

    install -D fennel $out/bin/fennel
    wrapProgram $out/bin/fennel \
      --prefix LUA_PATH ";" "$out/lib/lua/${lua.luaversion}/?.lua"
  '';
  
  meta = with stdenv.lib; {
    description = "Fennel (formerly fnl) is a lisp that compiles to Lua";
    homepage = https://github.com/bakpakin/Fennel;
    license = licenses.mit;
  };
}
