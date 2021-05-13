{ lib, unzip, buildLuarocksPackage, lua, luaposix, luaOlder }:

buildLuarocksPackage rec {
  pname = "awestore";
  version = "0.2.1-1";

  src = ./awestore.zip;

  nativeBuildInputs = [ unzip ];

  disabled = luaOlder "5.3";

  propagatedBuildInputs = [ lua luaposix ];

  meta = with lib; {
    homepage = "https://github.com/K4rakara/awestore";
    description = "Svelte's store API for AwesomeWM";
    maintainers = with maintainers; [ fortuneteller2k ];
    license = licenses.mit;
  };
}
