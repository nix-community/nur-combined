{ stdenv, moonscript, buildLuarocksPackage
, fetchFromGitHub
, earthshine
}:

buildLuarocksPackage rec {
  pname = "facade.nvim";
  version = "scm-1";

  # src = fetchFromGitHub {
  #   owner = "Shados"; repo = "earthshine";
  #   rev = "";
  #   sha256 = "0qhrgl96jpi1c8l331dxnjn81x721lb748vb86mv9n2kgf8maz70";
  # };
  src = ~/technotheca/artifacts/media/software/neovim/facade.nvim;

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


