{ lib
, stdenv
, pkgs
, fetchurl
, fetchFromGitHub
, cmake
, maintainers, conduit
, shared ? !stdenv.hostPlatform.isStatic,
...
}:

let
   onOffBool = b: if b then "ON" else "OFF";
   boost = pkgs.boost172.override { useMpi = true; };
in


stdenv.mkDerivation rec {
  pname = "conveyorlc";
  version = "1.1.2-1";

  # Updated when we have final versioned release - still a WIP
  # src = fetchurl {
  #  url = "https://github.com/XiaohuaZhangLLNL/conveyorlc/archive/v${version}.tar.gz";
  #  hash = "sha256-hRQcTdwrLCnpTIqY0qzNTLvQIhbuxzaxRFGFetqT9VE=";
  #};
  src = fetchFromGitHub {
    owner = "XiaohuaZhangLLNL";
    repo = "conveyorlc";
    rev = "7b791db3a516ddb950c2090228043350b092a503";
    hash = "sha256-JxfxD17b+hPDpf+ryhU9xijMn1MXwotnqe4W8QqUJY8=";
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
