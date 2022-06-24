{ lib, stdenv, fetchFromGitHub, kernel }:
let
  kdir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in
stdenv.mkDerivation rec {
  pname = "looking-glass-module";
  version = "ed0cae84c8ec3a7ba3777997c00b4cf7e3c71c40";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = version;
    sha256 = "sha256-bzfkbxo5/sJaN/wO5dqya9y+GsMFAj184hWt+UXWhyI=";
  };
  sourceRoot = "source/module";

  makeFlags = with kernel; [
    "KDIR=${kdir}"
  ];
  hardeningDisable = [ "pic" "format" ];
  installPhase = ''
    INSTALL_MOD_PATH="$out" make -C "${kdir}" "M=$PWD" modules_install
  '';

  meta = with lib; {
    description = "A kernel module which implements a basic interface to the IVSHMEM device for LookingGlass";
    homepage = "https://looking-glass.io/";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
  };
}
