{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "morse-talk";
  version = "2016-12-25";

  src = fetchFromGitHub {
    owner = "morse-talk";
    repo = "morse-talk";
    rev = "71e09ace0aa554d28cada5ee658e43758305b8fa";
    hash = "sha256-fvQCETz0Lv0hyfKG7HC2Whm+xoZ9233hF/1ogsfZ10o=";
  };

  propagatedBuildInputs = with python3Packages; [ matplotlib sounddevice tkinter ];

  checkInputs = with python3Packages; [ nose ];
  checkPhase = "nosetests";

  meta = with lib; {
    description = "A Python library written for Morse Code";
    inherit (src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
  };
}
