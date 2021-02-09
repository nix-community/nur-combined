{ lib, python3Packages, sources, withUI ? true }:

python3Packages.buildPythonApplication {
  pname = "gt4gd-unstable";
  version = lib.substring 0 10 sources.gt4gd.date;

  src = sources.gt4gd;

  propagatedBuildInputs = with python3Packages; [ requests ]
    ++ lib.optional withUI tkinter;

  doCheck = false;

  postInstall = lib.optionalString withUI ''
    install -Dm755 googletranslateui.py $out/bin/googletranslateui
    install -Dm644 google_translate.png -t $out/share/gt4gd
  '';

  meta = with lib; {
    inherit (sources.gt4gd) description homepage;
    license = licenses.gpl3;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
