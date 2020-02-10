{ lib, buildPythonApplication, lsdreader }:

buildPythonApplication rec {
  pname = "lsdreader";
  version = lib.substring 0 7 src.rev;
  src = lsdreader;

  doCheck = false;

  meta = with lib; {
    description = lsdreader.description;
    homepage = lsdreader.homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
