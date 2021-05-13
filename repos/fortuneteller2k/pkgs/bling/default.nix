{ lib, stdenv, toLuaModule, lua, fetchFromGitHub }:

toLuaModule(stdenv.mkDerivation rec {
  name = "bling-${version}";
  version = "unstable-2021-05-12";

  src = fetchFromGitHub {
    owner = "BlingCorp";
    repo = "bling";
    rev = "60c1e4735e379222e56fec3a11954ae48b04e9bb";
    sha256 = "sha256-fQ9JuIQSsNezuuFXbAOP90ueHJyjsvRnUlh3/BvWks0=";
  };

  buildInputs = [ lua ];

  installPhase = ''
    mkdir -p $out/lib/lua/${lua.luaversion}/
    cp -r . $out/lib/lua/${lua.luaversion}/bling/
    printf "package.path = '$out/lib/lua/${lua.luaversion}/?/init.lua;' ..  package.path\nreturn require((...) .. '.init')\n" > $out/lib/lua/${lua.luaversion}/bling.lua
  '';

  meta = with lib; {
    description = "Utilities for the awesome window manager";
    homepage = "https://blingcorp.github.io/bling/#/";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
})
