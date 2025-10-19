{
  lib,
  stdenv,
  moonscript,
  buildLuarocksPackage,
  pins,
}:

buildLuarocksPackage rec {
  pname = "earthshine";
  version = "scm-1";

  src = pins.earthshine.outPath;

  propagatedBuildInputs = [
    moonscript
  ];

  knownRockspec = "${pname}-${version}.rockspec";

  meta = with lib; {
    description = "A collection of MoonScript libraries I had a need for";
    homepage = "https://github.com/Shados/earthshine";
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.bsd2;
  };
}
