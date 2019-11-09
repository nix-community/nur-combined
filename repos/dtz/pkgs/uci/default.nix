{ stdenv, fetchgit, cmake, libubox }:

stdenv.mkDerivation rec {
  pname = "uci";
  version = "2019-11-04";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "fc417e808087f96466d9ce18819e16476af9527b";
    sha256 = "1ynsgz109bbvm3llmi1fcs7256lm5aq744qyamsfg2kwzz8ildlh";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
