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
    homepage = "https://github.com/jarun/imgp";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
