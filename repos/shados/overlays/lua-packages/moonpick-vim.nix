{
  lib,
  stdenv,
  moonscript,
  buildLuarocksPackage,
  pins,
  moonpick,
  isLua51,
  isLuaJIT,
}:
buildLuarocksPackage rec {
  pname = "moonpick-vim";
  version = "scm-1";

  src = pins.moonpick-vim.outPath;

  propagatedBuildInputs = [
    moonscript
    moonpick
  ];

  disabled = !(isLua51 || isLuaJIT);

  knownRockspec = "${pname}-${version}.rockspec";

  meta = with lib; {
    description = "ALE-based vim integration for moonpick";
    homepage = "https://github.com/Shados/moonpick-vim";
    hydraPlatforms = platforms.linux;
    maintainers = with maintainers; [ arobyn ];
    license = licenses.mit;
  };
}
