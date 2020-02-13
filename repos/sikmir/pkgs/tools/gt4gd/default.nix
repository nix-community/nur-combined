{ lib, buildPythonApplication, requests, sources }:

buildPythonApplication rec {
  pname = "gt4gd";
  version = lib.substring 0 7 src.rev;
  src = sources.google-translate-for-goldendict;

  propagatedBuildInputs = [ requests ];

  preConfigure = ''
    touch setup.py
  '';

  installPhase = ''
    install -Dm755 googletranslate.py $out/bin/gt4gd
    install -Dm644 google_translate.png $out/share/gt4gd/gt.png
  '';

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
