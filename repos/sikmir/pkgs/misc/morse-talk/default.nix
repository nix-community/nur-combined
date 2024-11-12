{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "morse-talk";
  version = "2016-12-25";

  src = fetchFromGitHub {
    owner = "morse-talk";
    repo = "morse-talk";
    rev = "71e09ace0aa554d28cada5ee658e43758305b8fa";
    hash = "sha256-fvQCETz0Lv0hyfKG7HC2Whm+xoZ9233hF/1ogsfZ10o=";
  };

  dependencies = with python3Packages; [
    matplotlib
    sounddevice
    tkinter
  ];

  meta = {
    description = "A Python library written for Morse Code";
    homepage = "https://github.com/morse-talk/morse-talk";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
