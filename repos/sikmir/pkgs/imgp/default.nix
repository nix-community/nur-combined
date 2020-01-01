{ lib, buildPythonApplication, pillow, imgp }:

buildPythonApplication rec {
  pname = "imgp";
  version = lib.substring 0 7 src.rev;
  src = imgp;

  propagatedBuildInputs = [ pillow ];

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  meta = with lib; {
    description = imgp.description;
    homepage = imgp.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
