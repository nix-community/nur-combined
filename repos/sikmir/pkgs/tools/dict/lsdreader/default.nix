{ lib, buildPythonApplication, sources }:

buildPythonApplication rec {
  pname = "lsdreader";
  version = lib.substring 0 7 src.rev;
  src = sources.lsdreader;

  doCheck = false;

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
