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
    rev = "45c85945b63a8835546e862fc667fadfde46a97d";
    sha256 = "01di417wlv40szjwak6wk73j6bqjgxnxfy216izsi78jlz5m8vm2";
  };

  buildInputs = [ qttools ];

  postPatch = ''
    sed -Ei "s:(WALLPAPERDIR=\"):\1$out:g" update-day-night-plasma-wallpapers.sh
  '';

  installPhase = ''
    install -Dm 555 update-day-night-plasma-wallpapers.sh $out/bin/update-day-night-plasma-wallpapers.sh
    install -D macOS-Mojave-Light/macOS-Mojave-Day-wallpaper.jpg $out/usr/share/wallpapers/macOS-Mojave-Light/macOS-Mojave-Day-wallpaper.jpg
    install -D macOS-Mojave-Night/macOS-Mojave-Night-wallpaper.jpg $out/usr/share/wallpapers/macOS-Mojave-Night/macOS-Mojave-Night-wallpaper.jpg
  '';

  meta = {
    description = "KDE Plasma utility to automatically change to a night wallpaper when the sun is reaching sunset.";
    license = lib.licenses.mit;
    homepage = "https://github.com/SCOTT-HAMILTON/Day-night-plasma-wallpapers";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = stdenv.lib.platforms.linux;
  };
}
