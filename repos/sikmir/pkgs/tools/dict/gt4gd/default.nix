{ lib, python3Packages, sources, withUI ? true }:
let
  pname = "gt4gd";
  date = lib.substring 0 10 sources.gt4gd.date;
  version = "unstable-" + date;
in
python3Packages.buildPythonApplication {
  inherit pname version;
  src = sources.gt4gd;

  propagatedBuildInputs = with python3Packages; [ requests ] ++ (lib.optional withUI tkinter);

  postInstall = lib.optionalString withUI ''
    install -Dm755 googletranslateui.py $out/bin/googletranslateui
    install -Dm644 google_translate.png -t $out/share/gt4gd
  '';

  meta = with lib; {
    inherit (sources.gt4gd) description homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
