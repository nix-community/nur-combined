{ stdenv, fetchgit, cmake, libubox }:

stdenv.mkDerivation rec {
  pname = "uci";
  version = "2019-07-18";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "415f9e48436d29f612348f58f546b3ad8d74ac38";
    sha256 = "186wc6n6rvs341m3i58w6ncl284s1mv4kdks2ddf1wpns6l1grxa";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
