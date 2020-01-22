{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2020-01-20";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "43a103ff17ee5872669f8712606578c90c14591d";
    sha256 = "0cihgckghamcfxrvqjjn69giib80xhsqaj98ldn0gd96zqh96sd4";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


