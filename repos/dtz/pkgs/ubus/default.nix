{ stdenv, fetchgit, cmake, json_c, libubox }:

stdenv.mkDerivation rec {
  pname = "ubus";
  version = "2019-06-14";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "2e051f62899666805d477830ef790e1149bc6a89";
    sha256 = "0dx7hxzrmhbcndbm500vjn147y4mxfxbbg60cj9rq7ix105szmzn";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ json_c libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
