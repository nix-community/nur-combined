{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2019-06-09";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "ecf56174da9614a0b3107d33def463eefb4d7785";
    sha256 = "01p832gnabhzav4b2q36q4zrfqhy7kijj9d15cn31hgppgpwgk72";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


