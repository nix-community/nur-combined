{ lua5_3, buildLuarocksPackage, fetchurl, dkjson, stdenv }:

buildLuarocksPackage {
  pname = "ln";
  version = "0.2.0-1";

  src = fetchurl {
    url    = https://luarocks.org/ln-0.2.0-1.src.rock;
    sha256 = "0ff0139d8fkyp35csfs75b1jn9q37v5y35wzml82ff35k0sgwkam";
  };
  propagatedBuildInputs = [ lua5_3 dkjson ];

  meta = with stdenv.lib; {
    homepage = "https://tulpa.dev/cadey/lua-ln";
    description = "The natural log function";
    license.fullName = "0bsd";
  };
}
