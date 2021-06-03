{ stdenv, moonscript, buildLuarocksPackage, pins
, earthshine
}:

buildLuarocksPackage rec {
  pname = "facade.nvim";
  version = "scm-1";

  src = pins."facade.nvim";

  propagatedBuildInputs = [
    earthshine
  ];

  knownRockspec = "${pname}-${version}.rockspec";

  meta = with stdenv.lib; {
    description = "A MoonScript wrapper around Neovim's Lua API";
    homepage = https://github.com/Shados/facade.nvim;
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.mit;
  };
}


