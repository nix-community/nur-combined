{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2019-11-23";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "07413cce72e19520af55dfcbc765484f5ab41dd9";
    sha256 = "0bbkmjq8gyzbjamzxpys4s911p8nnqffr636774imzdzm9skz01v";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


