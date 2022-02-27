{ lib, lua53Packages, fetchurl, curl, pkg-config }:

let inherit (lua53Packages) lua luaOlder luaAtLeast buildLuarocksPackage;
in buildLuarocksPackage rec {
  pname = "lua-curl";
  version = "0.3.12-1";
  src = fetchurl {
    url = "mirror://luarocks/lua-curl-${version}.src.rock";
    sha256 = "010wjqywr99n0a6gnq7n6rhcjq6srrm6kqf2qzr87n3a876n1f5n";
  };

  disabled = (luaOlder "5.3") || (luaAtLeast "5.5");

  buildInputs = [ curl.dev ];

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Lua binding to libcurl";
    homepage = "https://github.com/Lua-cURL/Lua-cURLv3";
    license = licenses.mit;
  };
}
