{ luaPackages, fetchurl, perl }:

luaPackages.buildLuaPackage {
  name = "luaposix-32";

  buildInputs = [ perl ];
  src = fetchurl {
    url = "https://github.com/luaposix/luaposix/archive/release-v32.tar.gz";
    sha256 = "09dbbde825fd9b76a8a1f6a80920434f8629a392cd1840021ed4b95b21fcf073";
  };
  meta = {
    homepage = "https://github.com/luaposix/luaposix";
  };
}
