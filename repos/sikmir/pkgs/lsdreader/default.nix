{ lib, buildPythonApplication, lsdreader }:

buildPythonApplication rec {
  pname = "lsdreader";
  version = lib.substring 0 7 src.rev;
  src = lsdreader;

  doCheck = false;

  meta = with lib; {
    description = lsdreader.description;
    homepage = "https://github.com/sv99/lsdreader";
    license = licenses.free;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
