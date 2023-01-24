{ lib, stdenv, python3}:

python3.pkgs.buildPythonPackage rec {
  pname = "drawille";
  version = "0.1.0";

  src = python3.pkgs.fetchPypi {
    inherit pname version;
    sha256 = "sha256-t4nS8TWbEGKHibIbLfZZycPQxTiEzuJ7DYsa6Twi+8s=";
  };

  meta = with lib; {
    description = " Pixel graphics in terminal with unicode braille characters";
    homepage = "https://github.com/asciimoo/drawille";
    license = licenses.gpl3;
    maintainers = with maintainers; [ renesat ];
  };
}
