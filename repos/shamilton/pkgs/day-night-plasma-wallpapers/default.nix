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
    rev = "07cfb47b6b960909c3b8274dff0dcefd18151bae";
    sha256 = "0vjnl5p1l50sfmvmmggzxajppyd58val7a35vlfzklmwiv24w5lc";
  };

  buildInputs = [ qttools ];

  patches = [ ./shebang-line.patch ];

  postPatch = ''
    sed -Ei "s:(Exec=)(/bin/update-day-night-plasma-wallpapers.sh):\1env PATH=\"${qttools.bin}/bin\" $out\2:g" day-night-plasma-wallpapers.desktop
    sed -Ei "s:(WALLPAPERDIR=\"):\1$out:g" update-day-night-plasma-wallpapers.sh
  '';

  installPhase = ''
    install -Dm 555 update-day-night-plasma-wallpapers.sh $out/bin/update-day-night-plasma-wallpapers.sh
    install -Dm 555 day-night-plasma-wallpapers.desktop $out/.config/autostart/day-night-plasma-wallpapers.desktop
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
