{ lib
, fetchFromGitLab
, python3Packages
, gettext
, ...
} @ args:

with python3Packages;

buildPythonPackage rec {
  pname = "genshinhelper2";
  version = "2.0.3";

  src = fetchFromGitLab {
    owner = "y1ndan";
    repo = pname;
    rev = version;
    sha256 = "sha256-AzYu3651ItE+UdW07sgecXTU3Im62fCQkLUC6FAxvvc=";
  };

  preConfigure = ''
    substituteInPlace setup.py --replace "'msgfmt'" "'${gettext}/bin/msgfmt'"
  '';

  buildInputs = [ gettext ];
  propagatedBuildInputs = [ requests beautifulsoup4 ];
  doCheck = false;

  meta = with lib; {
    description = "A Python library for miHoYo bbs and HoYoLAB Community.";
    homepage = "https://gitlab.com/y1ndan/genshinhelper2";
    license = with licenses; [ gpl3Only ];
  };
}
