{ stdenv, moonscript, buildLuarocksPackage, fetchFromGitHub
, moonpick
}:

buildLuarocksPackage rec {
  pname = "moonpick-vim";
  version = "scm-1";

  src = fetchFromGitHub {
    owner = "Shados"; repo = "moonpick-vim";
    rev = "1800643a7fc7c3a7f9601915b0a4e1548bacb4eb";
    sha256 = "1wkyf28d1daj24z310jpr0g3dh2igflfsiv8h3bh4lhb1mnfvili";
  };

  propagatedBuildInputs = [
    moonscript
    moonpick
  ];

  knownRockspec = "${pname}-${version}.rockspec";

  meta = with stdenv.lib; {
    description = "ALE-based vim integration for moonpick";
    homepage = https://github.com/Shados/moonpick-vim;
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.mit;
  };
}
