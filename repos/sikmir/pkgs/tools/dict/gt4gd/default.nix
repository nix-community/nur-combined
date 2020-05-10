{ lib, buildPythonApplication, requests, sources
, withUI ? true, tkinter }:

buildPythonApplication rec {
  pname = "gt4gd";
  version = lib.substring 0 7 src.rev;
  src = sources.google-translate-for-goldendict;

  propagatedBuildInputs = [ requests ] ++ (lib.optional withUI tkinter);

  postInstall = lib.optionalString withUI ''
    install -Dm755 googletranslateui.py $out/bin/googletranslateui
    install -Dm644 google_translate.png -t $out/share/gt4gd
  '';

  meta = with lib; {
    inherit (src) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
