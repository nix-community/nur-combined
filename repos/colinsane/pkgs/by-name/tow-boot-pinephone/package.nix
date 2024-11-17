{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "tow-boot-pinephone";
  version = "2021.10-004";

  src = fetchurl {
    url = "https://github.com/Tow-Boot/Tow-Boot/releases/download/release-2021.10-004/pine64-pinephoneA64-2021.10-004.tar.xz";
    sha256 = "sha256-UZSzzzTp8PQ/wuLUA3RJyTa/vbQ0HdhfagJ8574leoA=";
  };

  unpackPhase = ''
    mkdir -p src
    tar -xf ${src} -C src
  '';

  installPhase = ''
    mkdir -p "$out"
    cp -R src/pine64-pinephoneA64-2021.10-004/*.img "$out"/
    cp -R src/pine64-pinephoneA64-2021.10-004/binaries/* "$out"/
  '';


  meta = with lib; {
    description = "An opinionated distribution of U-Boot";
    homepage = "https://tow-boot.org/";
    platforms = [ "aarch64-linux" ];
  };
}

