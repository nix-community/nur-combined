{ stdenv, fetchgit, cmake, pkgconfig, json_c }:

stdenv.mkDerivation rec {
  pname = "libubox";
  version = "2019-12-28";

  src = fetchgit {
    url = "https://git.openwrt.org/project/${pname}.git";
    rev = "cd75136b1342e1e9dabf921be13240c6653640ed";
    sha256 = "0qgrx59z9qln4pnh0c8bkqmsgyirh1rq2rasskfim3sfv3awqhn6";
  };

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ json_c ];

  cmakeFlags = [ "-DBUILD_LUA=OFF" ];
}


