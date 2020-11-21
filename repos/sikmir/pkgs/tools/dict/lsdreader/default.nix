{ lib, python3Packages, sources }:

python3Packages.buildPythonApplication {
  pname = "lsdreader-unstable";
  version = lib.substring 0 10 sources.lsdreader.date;

  src = sources.lsdreader;

  doCheck = false;

  meta = with lib; {
    inherit (sources.lsdreader) description homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
