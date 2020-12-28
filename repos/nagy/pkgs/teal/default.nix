{ stdenv, lua53Packages, fetchurl }:
let
  inherit (lua53Packages) lua luaOlder luaAtLeast buildLuarocksPackage;
in buildLuarocksPackage rec {
  pname = "tl";
  version = "0.9.0-1";
  src = fetchurl {
    url = "https://luarocks.org/manifests/hisham/tl-0.9.0-1.src.rock";
    sha256 = "012ma153fprx0k8dh8pr01232wcgslwp1gycj53zlbrizldf36gd";
  };
  disabled = (luaOlder "5.3") || (luaAtLeast "5.5");
  propagatedBuildInputs = with lua53Packages ; [ compat53 argparse luafilesystem ];

  meta = with stdenv.lib; {
    description = "A typed Lua that compiles to Lua";
    homepage = "https://github.com/teal-language/tl/";
    license = licenses.mit;
  };
}
