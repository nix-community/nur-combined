{ stdenv, moonscript, buildLuarocksPackage
, fetchFromGitHub
}:

buildLuarocksPackage rec {
  pname = "earthshine";
  version = "scm-1";

  # src = fetchFromGitHub {
  #   owner = "Shados"; repo = "earthshine";
  #   rev = "";
  #   sha256 = "0qhrgl96jpi1c8l331dxnjn81x721lb748vb86mv9n2kgf8maz70";
  # };
  src = ~/technotheca/artifacts/media/software/lua/earthshine;

  propagatedBuildInputs = [
    moonscript
  ];

  knownRockspec = "${pname}-${version}.rockspec";

  meta = with stdenv.lib; {
    description = "A collection of MoonScript libraries I had a need for";
    homepage = https://github.com/Shados/earthshine;
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.bsd2;
  };
}

