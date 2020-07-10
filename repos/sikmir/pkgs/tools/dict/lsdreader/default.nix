{ lib, buildPythonApplication, sources }:
let
  pname = "lsdreader";
  date = lib.substring 0 10 sources.lsdreader.date;
  version = "unstable-" + date;
in
buildPythonApplication {
  inherit pname version;
  src = sources.lsdreader;

  doCheck = false;

  meta = with lib; {
    inherit (sources.lsdreader) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
