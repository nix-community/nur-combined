{ pkgs, lib, luaOlder, luaAtLeast, buildLuarocksPackage, fetchurl, curl, pkg-config }:

buildLuarocksPackage rec {
  pname = "lua-curl";
  version = "0.3.13-1";
  src = fetchurl {
    url = "mirror://luarocks/lua-curl-${version}.src.rock";
    sha256 = "sha256-ayzEhiH6w8t8FmlwVHXmemkygpukbvuaxYZGBISPjqI=";
  };

  disabled = (luaOlder "5.3") || (luaAtLeast "5.5");

  buildInputs = [ curl.dev ];

  nativeBuildInputs = [ pkg-config ];

  preBuild = ''
    cd Lua-cURLv3-*/
  '';

  meta = with pkgs.lib; {
    description = "Lua binding to libcurl";
    homepage = "https://github.com/Lua-cURL/Lua-cURLv3";
    license = licenses.mit;
  };
}
