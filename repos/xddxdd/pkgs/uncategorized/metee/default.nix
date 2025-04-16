{
  sources,
  lib,
  stdenv,
  cmake,
}:
stdenv.mkDerivation rec {
  inherit (sources.metee) pname version src;

  nativeBuildInputs = [ cmake ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "C library to access CSE/CSME/GSC firmware via a MEI interface";
    homepage = "https://github.com/intel/metee";
    license = lib.licenses.asl20;
    changelog = "https://github.com/intel/metee/releases/tag/${version}";
  };
}
