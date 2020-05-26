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
    sha256 = "0mhkp20mhrdrp70qa7gfzf8ydzpi7rs6z3m166h0qdh0xima56c2";
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
