{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2020-06-30";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "f4e9bf73ac5c0ee6b8f240e2a2100e70ca56d705";
    sha256 = "0355wmqhnwa34vdpjkayl6z6jhz9q0x2d2gqhhjbjr82vjcmd963";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


