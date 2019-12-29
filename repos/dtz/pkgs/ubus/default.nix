{ stdenv, fetchgit, cmake, json_c, libubox }:

stdenv.mkDerivation rec {
  pname = "ubus";
  version = "2019-12-27";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "041c9d1c052bb4936fd03240f7d0dd64aedda972";
    sha256 = "1lyis4knnlyb8yyq95kj4aw5y4r2xfcqnyfdx4n5ik2f4zwp7ars";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ json_c libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
