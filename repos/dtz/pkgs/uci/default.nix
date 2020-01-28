{ stdenv, fetchgit, cmake, libubox }:

stdenv.mkDerivation rec {
  pname = "uci";
  version = "2020-01-27";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "e8d83732f9eb571dce71aa915ff38a072579610b";
    sha256 = "1si8dh8zzw4j6m7387qciw2akfvl7c4779s8q5ns2ys6dn4sz6by";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libubox ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}
