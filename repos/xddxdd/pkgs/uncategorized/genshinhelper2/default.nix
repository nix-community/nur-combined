{
  lib,
  sources,
  python3Packages,
  gettext,
  ...
}:
with python3Packages;
buildPythonPackage rec {
  inherit (sources.genshinhelper2) pname version src;

  preConfigure = ''
    substituteInPlace setup.py --replace "'msgfmt'" "'${gettext}/bin/msgfmt'"
  '';

  buildInputs = [ gettext ];
  propagatedBuildInputs = [
    requests
    beautifulsoup4
  ];
  doCheck = false;

  meta = with lib; {
    mainProgram = "genshinhelper";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Python library for miHoYo bbs and HoYoLAB Community";
    homepage = "https://gitlab.com/y1ndan/genshinhelper2";
    license = with licenses; [ gpl3Only ];
  };
}
