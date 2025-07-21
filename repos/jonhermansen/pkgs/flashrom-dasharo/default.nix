{
  cmake,
  cmocka,
  edk2,
  fetchFromGitHub,
  git,
  lib,
  libftdi1,
  libusb1,
  meson,
  ninja,
  pciutils,
  pkg-config,
  sphinx,
  stdenv,
  superiotool,
}:

stdenv.mkDerivation rec {
  name = "flashrom-dasharo";
  version = "1.5.1";

  leaveDotGit = true;
  src = fetchFromGitHub {
    forceFetchGit = true;
    owner = "Dasharo";
    #owner = "flashrom";
    repo = "flashrom";
    rev = "fd38bcce890838d0156adc1b7d3897901948c58f";
    hash = "sha256-yQhBrFFvNxnseAETem8+QHVTIVDBZcduylRawa5r5xk=";
    #rev = "546c74e1fc65a009fdfed6d2e2989e8098d49964";
    #hash = "sha256-luksieDM/DzLVlqc7CBKut77Ht/SaiLVbvGJ+tnT/Sk=";
  };

  #NIX_CFLAGS_COMPILE = [ "-I${libftdi}/include" ];
  #NIX_LDFLAGS = [ "-L${libftdi}/lib" ];
  dontUseCmakeConfigure = true;
  dontFixCmake = true;
  withCMake = false;
  nativeBuildInputs = [
    cmake
    cmocka
    edk2
    git
    libftdi1
    libusb1
    meson
    ninja
    pciutils
    pkg-config
    sphinx
    superiotool
  ];
  #buildSteps = "ls -al";
}
