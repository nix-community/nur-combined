{ stdenv, fetchgit, cmake, libubox }:

stdenv.mkDerivation rec {
  pname = "uci";
  version = "2019-11-05";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "8dd50da20de0ece65118b2b4b71f8df8ac3a1f6d";
    sha256 = "078s0wfw8zdyx82fb8v3kw2iwdlgcvfh80cwk7wipq7aflh8bv5c";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
