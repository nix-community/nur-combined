{ stdenv, fetchgit, cmake, json_c, ubus, uci, libubox }:

stdenv.mkDerivation rec {
  pname = "ubox";
  version = "2019-06-15";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "4df34a4d0d5183135217fc8280faae8e697147bc";
    sha256 = "0rz2rfd22g6vxaxqawasayycvag56hx4362rr2vz5bghcbx5zlfn";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ json_c ubus uci libubox ];
}

