{ lib, lua53Packages, fetchurl }:
let
  inherit (lua53Packages) lua luaOlder luaAtLeast buildLuarocksPackage;
in buildLuarocksPackage rec {
  pname = "tl";
  version = "0.13.2-1";
  src = fetchurl {
    url = "mirror://luarocks/tl-${version}.src.rock";
    sha256 = "13zq2gqsds9s4xxk50xp89i29kaf33cad9ngcpf5chh028nw03is";
  };

  disabled = (luaOlder "5.3") || (luaAtLeast "5.5");

  propagatedBuildInputs = with lua53Packages ; [ compat53 argparse luafilesystem ];

  meta = with lib; {
    description = "A typed Lua that compiles to Lua";
    homepage = "https://github.com/teal-language/tl/";
    license = licenses.mit;
  };
}
