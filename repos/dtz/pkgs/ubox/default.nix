{ stdenv, fetchgit, cmake, json_c, ubus, uci, libubox }:

stdenv.mkDerivation rec {
  pname = "ubox";
  version = "2019-10-22";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "17689b61a1cdc05b2c27fc5a33407e1a3c384137";
    sha256 = "1jnkvxpik5hy0iq7shrvs9h1z98y69xr8mg93qcgp4jn5lf0h90h";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ json_c ubus uci libubox ];
}

