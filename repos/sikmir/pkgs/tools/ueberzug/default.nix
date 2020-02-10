{ lib, buildPythonApplication, libX11, libXext, xlib, pillow, docopt, psutil
, attrs, ueberzug }:

buildPythonApplication rec {
  pname = "ueberzug";
  version = lib.substring 0 7 src.rev;
  src = ueberzug;

  buildInputs = [ libX11 libXext ];
  propagatedBuildInputs = [ xlib pillow docopt psutil attrs ];

  meta = with lib; {
    description = ueberzug.description;
    homepage = ueberzug.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
