{ stdenv, fetchFromGitHub
, avrgcc, avrbinutils
, gcc-arm-embedded, gcc-armhf-embedded
, teensy-loader-cli, dfu-programmer, dfu-util }:


stdenv.mkDerivation rec { 
  name = "klipper";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "KevinOConnor";
    repo = "klipper";
    sha256 = "sha256:0f0bz9pdn4dwfdlcb3sjksg1livmb86y7h020jcx6j83qw1k773p";
    rev = "v${version}";
  };
  nativeBuildInputs = [
    avrgcc
    avrbinutils
    gcc-arm-embedded
    gcc-armhf-embedded
    teensy-loader-cli
    dfu-programmer
    dfu-util
  ];

}


