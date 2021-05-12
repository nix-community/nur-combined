{ stdenv, lua, toLuaModule
}:
toLuaModule (stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "cparser";
  version = "unstable-2021-05-04";
  src = (import ../../nix/sources.nix).cparser;

  buildPhase = ":";
  installPhase = let
    luaPath = "$out/share/lua/${lua.luaversion}";
  in ''
    install -d ${luaPath}
    cp -v cparser.lua ${luaPath}/

    install -D -m755 lcdecl $out/bin/lcdecl
    install -D -m755 lcpp $out/bin/lcpp
  '';
})
