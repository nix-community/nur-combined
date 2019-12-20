{ stdenv, lib, fetchFromGitHub, pkgconfig, meson, ninja }:

with lib;

stdenv.mkDerivation rec {
  pname = "rlottie-tdesktop";
  version = "c490c7a-1";

  src = fetchFromGitHub {
    owner = "desktop-app";
    repo = "rlottie";
    rev = "c490c7a098b9b3cbc3195b00e90d6fc3989e2ba2";
    sha256 = "1x9m6p07n5pchshw34318k1wkqdymcgnzjhqz21rizswv7c6qhyi";
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkgconfig meson ninja ];
  enableParallelBuilding = true;

  meta = {
    description = "A platform independent standalone library that plays Lottie Animation (tdesktop fork)";
    longDescription = ''
      rlottie is a platform independent standalone c++ library for rendering vector based animations and art in realtime.
    '';
    license = licenses.lgpl21;
    platforms = platforms.linux;
    homepage = https://github.com/desktop-app/rlottie;
  };
}
