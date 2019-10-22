{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2019-09-14";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "eb30a03048f83e733a9530b5741808d7d0932ff2";
    sha256 = "1xrfjcnrw5661vygrk21d661prdfi49fallwdlx3s2cd0splmpq5";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


