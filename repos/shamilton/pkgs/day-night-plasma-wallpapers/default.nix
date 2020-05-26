{ lib
, stdenv
, fetchFromGitHub
, qttools
, coreutils
}:
stdenv.mkDerivation rec {

  pname = "day-night-plasma-wallpapers";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "Day-night-plasma-wallpapers";
    rev = "master";
    sha256 = "0b9m0dycw2x3c4lhl677w6wbrcpgs983h8ynz6ird33x281pfs6q";
  };

  buildInputs = [ qttools ];

  installPhase = ''
    install -Dm 555 update-day-night-plasma-wallpapers.sh $out/bin/update-day-night-plasma-wallpapers.sh
    install -Dm 555 update-day-night-plasma-wallpapers.sh $out/.config/autostart-scripts/update-day-night-plasma-wallpapers.sh
  '';

  meta = {
    description = "KDE Plasma utility to automatically change to a night wallpaper when the sun is reaching sunset.";
    license = lib.licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Day-night-plasma-wallpapers";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = stdenv.lib.platforms.linux;
  };
}
