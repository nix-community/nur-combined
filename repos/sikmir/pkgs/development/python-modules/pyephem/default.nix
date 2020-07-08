{ lib, buildPythonPackage, sources }:

buildPythonPackage {
  pname = "pyephem";
  version = lib.substring 0 7 sources.pyephem.rev;
  src = sources.pyephem;

  meta = with lib; {
    inherit (sources.pyephem) description homepage;
    license = licenses.lgpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
