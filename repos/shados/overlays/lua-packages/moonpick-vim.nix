{ stdenv, moonscript, buildLuarocksPackage
, moonpick
, isLua51, isLuaJIT
}:
buildLuarocksPackage rec {
  pname = "moonpick-vim";
  version = "scm-1";

  src = (import ../../nix/sources.nix).moonpick-vim;

  propagatedBuildInputs = [
    moonscript
    moonpick
  ];

  disabled = !(isLua51 || isLuaJIT);

  knownRockspec = "${pname}-${version}.rockspec";

  meta = with stdenv.lib; {
    description = "ALE-based vim integration for moonpick";
    homepage = https://github.com/Shados/moonpick-vim;
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.mit;
  };
}
