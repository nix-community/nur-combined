{ lib, stdenv, fetchFromGitHub, kernel }:
let
  kdir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in
stdenv.mkDerivation rec {
  pname = "looking-glass-module";
  version = "30c3b399f28bdd2afb2d574a997a1dd0924fe892";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = version;
    sha256 = "1pfgn3a5qfwplhkz462zl4k04zbd8nzvfy60n9jdyx55ysk3jifm";
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
