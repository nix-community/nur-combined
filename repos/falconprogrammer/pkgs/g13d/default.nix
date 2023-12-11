{ lib
, stdenv
, fetchFromGitHub
, cmake
, log4cpp
, libusb
, libevdev
, gtest
}:

stdenv.mkDerivation rec {
  pname = "g13";
  version = "master-2020-09-09";

  src = fetchFromGitHub {
    owner = "khampf";
    repo = "g13";
    rev = "1e80eda4adc4fdd2d7ca1c2a963265ebab39d363";
    hash = "sha256-bwldZb8HZYvSI0bzl2eM+C+7sp3dUEJ3F6sgqCmFliY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    log4cpp
    libusb
    libevdev
    gtest
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp g13d $out/bin
  '';

  meta = with lib; {
    description = "Libusb driver for the g13";
    homepage = "https://github.com/khampf/g13";
    #license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "g13";
    platforms = platforms.all;
  };
}
