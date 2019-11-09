{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2019-10-29";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "301303911dded723b7eda4d6a4a933b22d2c1b60";
    sha256 = "0xlzcrhyich08m9ikbbcdh5jf8na6f6qyr243g6jfk8k3r2rjqc2";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


