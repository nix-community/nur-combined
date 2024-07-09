{ lib
, python3Packages
, fetchFromGitHub
, xvfb-run
, scrot
, gnome-screenshot
, which
, util-linux
, xorg
}:
let
  xlib-fixed = python3Packages.xlib.override {
    nose = python3Packages.pynose;
  };
in
python3Packages.buildPythonPackage rec {
  pname = "PyScreeze-fixed";
  version = "2023-06-14";

  src = fetchFromGitHub {
    owner = "asweigart";
    repo = "pyscreeze";
    rev = "eeca245a135cf171c163b3691300138518efa64e";
    sha256 = "sha256-DH/ehS1LolOlyftX6icLru94ZZuCguMFE+KJ3snLjkg=";
  };
  patches = [ ./find-gnome-screenshot.patch ];
  # src = nix-gitignore.gitignoreSource [ ] /home/scott/GIT/pyscreeze;

  nativeBuildInputs = [ xvfb-run python3Packages.pytest scrot gnome-screenshot ];
  propagatedBuildInputs = with python3Packages; [
    pillow
  ];
  checkInputs = with python3Packages; [ pytest xlib-fixed scrot pillow gnome-screenshot which ];

  doCheck = true;
  checkPhase = ''
    XDG_SESSION_TYPE=x11 xvfb-run -s '-screen 0 800x600x24' \
      pytest
  '';

  meta = with lib; {
    description = "Simple, cross-platform screenshot module for Python 2 and 3";
    homepage = "https://github.com/asweigart/pyscreeze";
    license = licenses.bsd3;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
