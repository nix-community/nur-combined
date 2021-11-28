{ lib
, fetchFromGitLab
, python3Packages
, onepush
, genshinhelper2
, ...
} @ args:

with python3Packages;

let
  setupPy = ./setup.py;
in
buildPythonApplication rec {
  pname = "genshin-checkin-helper";
  version = "1.0.3";

  src = fetchFromGitLab {
    owner = "y1ndan";
    repo = pname;
    rev = version;
    sha256 = "sha256-l+l6HoKJP5XSnwXtyUivpz9MAWjcfpO/KxsKCeuoZRs=";
  };

  preConfigure = ''
    cp ${setupPy} setup.py
  '';

  propagatedBuildInputs = [ schedule onepush genshinhelper2 ];
  doCheck = false;

  meta = with lib; {
    description = "More than check-in for Genshin Impact.";
    homepage = "https://gitlab.com/y1ndan/genshin-checkin-helper";
    license = with licenses; [ gpl3Only ];
  };
}
