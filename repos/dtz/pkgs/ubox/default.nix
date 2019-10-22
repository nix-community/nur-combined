{ stdenv, fetchgit, cmake, json_c, ubus, uci, libubox }:

stdenv.mkDerivation rec {
  pname = "ubox";
  version = "2019-10-20";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "c9ffeac74a3de0ea6cd6b79b9ce9238668be388c";
    sha256 = "0m0gndj8dxkb1lv11x5h1cq28cx6sibqgwasbn6bvz2fycvdrivf";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ json_c ubus uci libubox ];
}

