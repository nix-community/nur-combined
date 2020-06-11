{ stdenv, lua, toLuaModule, fetchFromGitHub
}:
toLuaModule (stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "cparser";
  version = "unstable-2019-05-21";
  src = fetchFromGitHub {
    owner = "facebookresearch"; repo = "CParser";
    rev = "7e4e633961db158a3e8bee9b5c263fbfe2d6a3f2";
    sha256 = "0v9n6dhsrjf9dqsi73n7bgl562kfy682hd1mr4sykil957dci0k9";
  };

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
