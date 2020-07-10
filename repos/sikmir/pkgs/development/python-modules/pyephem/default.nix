{ lib, buildPythonPackage, sources }:
let
  pname = "pyephem";
  date = lib.substring 0 10 sources.pyephem.date;
  version = "unstable-" + date;
in
buildPythonPackage {
  inherit pname version;
  src = sources.pyephem;

  meta = with lib; {
    inherit (sources.pyephem) description homepage;
    license = licenses.lgpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
