{ lib, buildPythonPackage, sources }:

buildPythonPackage rec {
  pname = "pyephem";
  version = lib.substring 0 7 src.rev;
  src = sources.pyephem;

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.lgpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
