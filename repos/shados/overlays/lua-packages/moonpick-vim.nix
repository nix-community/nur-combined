{ stdenv, moonscript, buildLuarocksPackage, fetchFromGitHub
, moonpick
}:

buildLuarocksPackage rec {
  pname = "moonpick-vim";
  version = "scm-1";

  src = fetchFromGitHub {
    owner = "Shados"; repo = "moonpick-vim";
    rev = "b9252660b44b270cc3bc933053fccb3788e12fd4";
    sha256 = "06sg2najn14vg4wb2nl6pbswv224sznn3m8ba9lw9irlyg40f3iz";
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
