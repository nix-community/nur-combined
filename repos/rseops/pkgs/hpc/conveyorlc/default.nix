{ lib, stdenv, pkgs, fetchurl, fetchFromGitHub, cmake, maintainers, conduit
, shared ? !stdenv.hostPlatform.isStatic,
...
}:

let
   onOffBool = b: if b then "ON" else "OFF";
   boost = pkgs.boost172.override { useMpi = true; };
in


stdenv.mkDerivation rec {
  pname = "conveyorlc";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "XiaohuaZhangLLNL";
    repo = "conveyorlc";
    rev = "efb98b021edd5ef230eaff257ce2534ea01ab1ba";
    sha256 = "sha256-L/pWqKFM1/68X9HPHKMBYODlDI3Jh4IVqffDGjVNCrc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [cmake pkgs.extra-cmake-modules];
  buildInputs = [
      boost
      pkgs.openmpi
      pkgs.openbabel2
      pkgs.zlib
      pkgs.hdf5-cpp
      pkgs.sqlite
      conduit
  ];

  # We set the conduit paths from Nix instead
  preConfigure = ''
   rm cmake/FindConduit.cmake
  '';

  cmakeFlags = [
    "-DCONDUIT_DIR=${lib.getDev conduit}"
    "-DCONDUIT_FOUND=TRUE"
    "-DCONDUIT_INCLUDE_DIRS=${lib.getDev conduit}/include/conduit"
    "-DCONDUIT_CMAKE_CONFIG_DIR=${lib.getDev conduit}/lib/cmake/conduit"
    "-DCMAKE_CXX_FLAGS=-lhdf5"
    "-DHDF5_ROOT=${lib.getDev pkgs.hdf5-cpp}"
    "-DOPENBABEL3_INCLUDE_DIRS=${lib.getDev pkgs.openbabel2}/include/openbabel-2.0"
  ];

  meta = with lib; {
    description = "A Parallel Virtual Screening Pipeline for Docking and MM/GSBA";
    longDescription = ''
      An open source project from Lawrence Livermore National
      Laboratory that provides a parallel virtual screening pipeline
      for docking and MM/GSBA
    '';
    homepage = "https://github.com/XiaohuaZhangLLNL/conveyorlc";
    license = licenses.gpl3;
    maintainers = [ maintainers.vsoch ];
    platforms = platforms.linux;
  };
}
