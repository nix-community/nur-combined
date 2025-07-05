{ lib
, stdenv
, fetchFromGitHub
, cmake
, log4cpp
, libusb1
, libevdev
, gtest
}:

stdenv.mkDerivation rec {
  pname = "g13";
  version = "master-2024-12-30";

  src = fetchFromGitHub {
    owner = "khampf";
    repo = "g13";
    rev = "acea10b7ae7b673a0b41545c71084c9b9b63d1d7";
    hash = "sha256-RKqf9CsEEomffcgQj2PTZzWbotGDb21zckbXVUTfEp8=";
  };

  patches = [
    ./fix-algorithm-include.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    log4cpp
    libusb1
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
