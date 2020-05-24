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
    rev = "6e30a43b5eb6f3e3fa8d8742da04efcf4fa2f8aa";
    sha256 = "0c7mgz30hxgraxnq7ryqifj8ksv21jhwxik53lshxy230yxpkidx";
  };

  buildInputs = [ qttools ];

  patches = [ ./shebang-line.patch ];

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
