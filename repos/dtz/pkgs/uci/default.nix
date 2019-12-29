{ stdenv, fetchgit, cmake, libubox }:

stdenv.mkDerivation rec {
  pname = "uci";
  version = "2019-11-30";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "165b444131453d63fc78c1d86f23c3ca36a2ffd7";
    sha256 = "056mcm4pm02q8dglcq4s4fdi0zfmdigmlgc5nswdq12hq93k46fw";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
