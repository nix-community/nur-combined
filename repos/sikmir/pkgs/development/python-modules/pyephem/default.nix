{ lib, python3Packages, sources }:
let
  pname = "pyephem";
  date = lib.substring 0 10 sources.pyephem.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonPackage {
  inherit pname version;
  src = sources.pyephem;

  meta = with lib; {
    inherit (sources.pyephem) description homepage;
    license = licenses.lgpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
