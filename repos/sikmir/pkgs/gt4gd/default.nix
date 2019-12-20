{ lib, buildPythonApplication, requests, google-translate-for-goldendict }:

buildPythonApplication rec {
  pname = "gt4gd";
  version = lib.substring 0 7 src.rev;
  src = google-translate-for-goldendict;

  propagatedBuildInputs = [ requests ];

  preConfigure = ''
    touch setup.py
  '';

  installPhase = ''
    install -Dm755 googletranslate.py $out/bin/gt4gd
    install -Dm644 google_translate.png $out/share/gt4gd/gt.png
  '';

  meta = with lib; {
    description = google-translate-for-goldendict.description;
    homepage = "https://github.com/xinebf/google-translate-for-goldendict";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ sikmir ];
  };
}
