{
  stdenv,
  lua,
  toLuaModule,
  pins,
}:
toLuaModule (
  stdenv.mkDerivation rec {
    name = "${pname}-${version}";
    pname = "cparser";
    version = "unstable-2021-05-04";
    src = pins.cparser.outPath;

    buildPhase = ":";
    installPhase =
      let
        luaPath = "$out/share/lua/${lua.luaversion}";
      in
      ''
        install -d ${luaPath}
        cp -v cparser.lua ${luaPath}/

        install -D -m755 lcdecl $out/bin/lcdecl
        install -D -m755 lcpp $out/bin/lcpp
      '';
  }
)
