{ lib, buildLuarocksPackage, fetchurl, curl }:

buildLuarocksPackage rec {
  pname = "lua-curl";
  version = "0.3.13-1";
  src = fetchurl {
    url = "mirror://luarocks/lua-curl-${version}.src.rock";
    sha256 = "sha256-ayzEhiH6w8t8FmlwVHXmemkygpukbvuaxYZGBISPjqI=";
  };

  buildInputs = [ curl ];

  sourceRoot =
    "${pname}-${version}/Lua-cURLv3-${lib.removeSuffix "-1" version}/";

  meta = with lib; {
    description = "Lua binding to libcurl";
    homepage = "https://github.com/Lua-cURL/Lua-cURLv3";
    license = licenses.mit;
  };
}
