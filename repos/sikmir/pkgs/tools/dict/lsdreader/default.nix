{ lib, python3Packages, sources }:
let
  pname = "lsdreader";
  date = lib.substring 0 10 sources.lsdreader.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.lsdreader;

  doCheck = false;

  meta = with lib; {
    inherit (sources.lsdreader) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
