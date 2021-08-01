{ lib
, stdenv
, fetchFromGitHub
, python3Packages
, coreutils
}:

stdenv.mkDerivation rec {
  pname = "day-night-plasma-wallpapers";
  version = "2020-05-30";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Day-night-plasma-wallpapers";
    rev = "1f6124fbc4f1297ada77d6d3155b5b494455c316";
    sha256 = "0ribzd0svp9sp0j87lhfqb7kivh3hw38ldvr5ps8qkr778460fdl";
  };

  propagatedBuildInputs = with python3Packages; [ dbus-python ];

  installPhase = ''
    install -Dm 555 update-day-night-plasma-wallpapers.py $out/bin/update-day-night-plasma-wallpapers.py
    install -Dm 555 update-day-night-plasma-wallpapers.py $out/.config/autostart-scripts/update-day-night-plasma-wallpapers.py
  '';

  meta = with lib; {
    description = "KDE Plasma utility to automatically change to a night wallpaper when the sun is reaching sunset";
    license = licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Day-night-plasma-wallpapers";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
