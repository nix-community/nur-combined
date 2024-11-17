{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "tow-boot-rpi4";
  version = "2021.10-004";

  src = fetchurl {
    url = "https://github.com/Tow-Boot/Tow-Boot/releases/download/release-2021.10-004/raspberryPi-aarch64-2021.10-004.tar.xz";
    sha256 = "sha256-dO8dFRF8BpJbmWYHAdeLEHZFwcaYcsqgUnA3gLYb2po=";
  };

  unpackPhase = ''
    mkdir -p src
    tar -xf ${src} -C src
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -R src/raspberryPi-aarch64-2021.10-004/*.img "$out"/
    cp -R src/raspberryPi-aarch64-2021.10-004/binaries/* "$out"/
  '';


  meta = with lib; {
    description = "An opinionated distribution of U-Boot";
    homepage = "https://tow-boot.org/";
    platforms = [ "aarch64-linux" ];
  };
}

